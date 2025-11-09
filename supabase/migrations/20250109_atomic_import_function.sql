-- Deutsche Lernen - Atomic Import Function
-- Version: 2.0
-- Created: 2025-11-09
-- Description: Atomic CSV import with de-duplication and transaction safety

-- ============================================================================
-- ATOMIC IMPORT FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION import_lesson_atomic(
  p_user_id UUID,
  p_lesson_number INTEGER,
  p_lesson_name TEXT DEFAULT NULL,
  p_rows JSONB
) RETURNS JSONB AS $$
DECLARE
  v_lesson_id UUID;
  v_term_id UUID;
  v_row JSONB;
  v_german TEXT;
  v_part_of_speech part_of_speech;
  v_gender gender;
  v_category TEXT;
  v_subcategory TEXT;
  v_order_index INTEGER;

  -- Counters for result
  v_created_terms INTEGER := 0;
  v_reused_terms INTEGER := 0;
  v_created_translations INTEGER := 0;
  v_updated_translations INTEGER := 0;
  v_linked_to_lesson INTEGER := 0;
  v_errors JSONB := '[]'::JSONB;

BEGIN
  -- Input validation
  IF p_user_id IS NULL THEN
    RAISE EXCEPTION 'User ID is required';
  END IF;

  IF p_lesson_number IS NULL OR p_lesson_number < 1 THEN
    RAISE EXCEPTION 'Valid lesson number is required';
  END IF;

  IF p_rows IS NULL OR jsonb_array_length(p_rows) = 0 THEN
    RAISE EXCEPTION 'No rows to import';
  END IF;

  -- Start transaction (implicit in function)

  -- Create or get lesson
  INSERT INTO public.lessons (created_by, lesson_number, lesson_name)
  VALUES (p_user_id, p_lesson_number, p_lesson_name)
  ON CONFLICT (created_by, lesson_number)
  DO UPDATE SET lesson_name = COALESCE(EXCLUDED.lesson_name, lessons.lesson_name)
  RETURNING id INTO v_lesson_id;

  -- Process each row
  v_order_index := 0;
  FOR v_row IN SELECT * FROM jsonb_array_elements(p_rows)
  LOOP
    BEGIN
      -- Extract and validate German term
      v_german := trim(v_row->>'german');
      IF v_german IS NULL OR v_german = '' THEN
        v_errors := v_errors || jsonb_build_object(
          'german', v_row->>'german',
          'error', 'Missing required field: german'
        );
        CONTINUE;
      END IF;

      -- Extract part of speech (default: 'other')
      v_part_of_speech := COALESCE(
        lower(v_row->>'part_of_speech')::part_of_speech,
        'other'::part_of_speech
      );

      -- Extract gender (default: 'none')
      v_gender := COALESCE(
        lower(v_row->>'gender')::gender,
        'none'::gender
      );

      -- Extract category
      v_category := trim(v_row->>'category');
      IF v_category IS NULL OR v_category = '' THEN
        v_errors := v_errors || jsonb_build_object(
          'german', v_german,
          'error', 'Missing required field: category'
        );
        CONTINUE;
      END IF;

      -- Extract subcategory (optional)
      v_subcategory := NULLIF(trim(v_row->>'subcategory'), '');

      -- Create or get term (de-duplication)
      INSERT INTO public.terms (german, part, gender, created_by)
      VALUES (v_german, v_part_of_speech, v_gender, p_user_id)
      ON CONFLICT (german) DO UPDATE SET
        part = EXCLUDED.part,
        gender = EXCLUDED.gender,
        updated_at = now()
      RETURNING id, (xmax = 0) as is_new INTO v_term_id, v_created_terms;

      -- Track created vs reused
      IF v_created_terms THEN
        v_created_terms := v_created_terms + 1;
      ELSE
        v_reused_terms := v_reused_terms + 1;
      END IF;

      -- Insert/update translations
      -- Hebrew
      IF v_row->>'hebrew' IS NOT NULL AND trim(v_row->>'hebrew') != '' THEN
        INSERT INTO public.term_translations (term_id, lang, text)
        VALUES (v_term_id, 'he', trim(v_row->>'hebrew'))
        ON CONFLICT (term_id, lang) DO UPDATE SET
          text = EXCLUDED.text
        RETURNING (xmax = 0) INTO v_created_translations;

        IF v_created_translations THEN
          v_created_translations := v_created_translations + 1;
        ELSE
          v_updated_translations := v_updated_translations + 1;
        END IF;
      END IF;

      -- English
      IF v_row->>'english' IS NOT NULL AND trim(v_row->>'english') != '' THEN
        INSERT INTO public.term_translations (term_id, lang, text)
        VALUES (v_term_id, 'en', trim(v_row->>'english'))
        ON CONFLICT (term_id, lang) DO UPDATE SET
          text = EXCLUDED.text
        RETURNING (xmax = 0) INTO v_created_translations;

        IF v_created_translations THEN
          v_created_translations := v_created_translations + 1;
        ELSE
          v_updated_translations := v_updated_translations + 1;
        END IF;
      END IF;

      -- Italian
      IF v_row->>'italian' IS NOT NULL AND trim(v_row->>'italian') != '' THEN
        INSERT INTO public.term_translations (term_id, lang, text)
        VALUES (v_term_id, 'it', trim(v_row->>'italian'))
        ON CONFLICT (term_id, lang) DO UPDATE SET
          text = EXCLUDED.text
        RETURNING (xmax = 0) INTO v_created_translations;

        IF v_created_translations THEN
          v_created_translations := v_created_translations + 1;
        ELSE
          v_updated_translations := v_updated_translations + 1;
        END IF;
      END IF;

      -- Link term to lesson
      INSERT INTO public.lesson_terms (
        lesson_id,
        term_id,
        category,
        subcategory,
        order_index
      )
      VALUES (
        v_lesson_id,
        v_term_id,
        v_category,
        v_subcategory,
        v_order_index
      )
      ON CONFLICT (lesson_id, term_id) DO UPDATE SET
        category = EXCLUDED.category,
        subcategory = EXCLUDED.subcategory,
        order_index = EXCLUDED.order_index;

      v_linked_to_lesson := v_linked_to_lesson + 1;
      v_order_index := v_order_index + 1;

    EXCEPTION WHEN OTHERS THEN
      -- Log error and continue with next row
      v_errors := v_errors || jsonb_build_object(
        'german', v_german,
        'error', SQLERRM
      );
    END;
  END LOOP;

  -- Return result summary
  RETURN jsonb_build_object(
    'success', true,
    'lesson_id', v_lesson_id,
    'summary', jsonb_build_object(
      'total_rows', jsonb_array_length(p_rows),
      'created_terms', v_created_terms,
      'reused_terms', v_reused_terms,
      'created_translations', v_created_translations,
      'updated_translations', v_updated_translations,
      'linked_to_lesson', v_linked_to_lesson,
      'error_count', jsonb_array_length(v_errors)
    ),
    'errors', v_errors
  );

EXCEPTION WHEN OTHERS THEN
  -- Rollback happens automatically
  RAISE EXCEPTION 'Import failed: %', SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION import_lesson_atomic IS 'Atomically import lesson data with de-duplication';

-- ============================================================================
-- USAGE EXAMPLE
-- ============================================================================

/*
SELECT import_lesson_atomic(
  p_user_id := auth.uid(),
  p_lesson_number := 1,
  p_lesson_name := 'Lesson 1: Introduction',
  p_rows := '[
    {
      "german": "ich bin",
      "hebrew": "אני",
      "english": "I am",
      "italian": "io sono",
      "part_of_speech": "verb",
      "gender": "none",
      "category": "Verbs",
      "subcategory": "sein"
    },
    {
      "german": "Tisch",
      "hebrew": "שולחן",
      "english": "table",
      "italian": "tavolo",
      "part_of_speech": "noun",
      "gender": "der",
      "category": "Nouns",
      "subcategory": "Furniture"
    }
  ]'::JSONB
);
*/
