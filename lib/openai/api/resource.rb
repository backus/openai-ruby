# frozen_string_literal: true

class OpenAI
  class API
    class Resource
      include Concord.new(:client)
      include AbstractType

      private

      def post(...)
        client.post(...)
      end

      def post_form_multipart(...)
        client.post_form_multipart(...)
      end

      def get(...)
        client.get(...)
      end

      def form_file(path)
        absolute_path = Pathname.new(path).expand_path.to_s
        HTTP::FormData::File.new(absolute_path)
      end

      def create_and_maybe_stream(
        endpoint,
        full_response_type:, stream: false,
        chunk_response_type: full_response_type,
        **kwargs
      )
        payload = kwargs.merge(stream:)

        raise 'Streaming responses require a block' if stream && !block_given?
        raise 'Non-streaming responses do not support blocks' if !stream && block_given?

        if stream
          post(endpoint, **payload) do |chunk|
            yield(chunk_response_type.from_json(chunk))
          end

          nil
        else
          full_response_type.from_json(
            post(endpoint, **payload)
          )
        end
      end
    end

    class Completion < Resource
      def create(model:, **, &block)
        create_and_maybe_stream(
          '/v1/completions',
          model:,
          full_response_type: Response::Completion,
          **,
          &block
        )
      end
    end

    class ChatCompletion < Resource
      def create(model:, messages:, **, &block)
        create_and_maybe_stream(
          '/v1/chat/completions',
          model:,
          messages:,
          full_response_type: Response::ChatCompletion,
          chunk_response_type: Response::ChatCompletionChunk,
          **,
          &block
        )
      end
    end

    class Embedding < Resource
      def create(model:, input:, **)
        Response::Embedding.from_json(
          post('/v1/embeddings', model:, input:, **)
        )
      end
    end

    class Model < Resource
      def list
        Response::ListModel.from_json(get('/v1/models'))
      end

      def fetch(model_id)
        Response::Model.from_json(
          get("/v1/models/#{model_id}")
        )
      end
    end

    class Moderation < Resource
      def create(input:, model:)
        Response::Moderation.from_json(
          post('/v1/moderations', input:, model:)
        )
      end
    end

    class Edit < Resource
      def create(model:, instruction:, **)
        Response::Edit.from_json(
          post('/v1/edits', model:, instruction:, **)
        )
      end
    end

    class File < Resource
      def create(file:, purpose:)
        Response::File.from_json(
          post_form_multipart('/v1/files', file: form_file(file), purpose:)
        )
      end

      def list
        Response::FileList.from_json(
          get('/v1/files')
        )
      end

      def delete(file_id)
        Response::File.from_json(
          client.delete("/v1/files/#{file_id}")
        )
      end

      def fetch(file_id)
        Response::File.from_json(
          get("/v1/files/#{file_id}")
        )
      end

      def get_content(file_id)
        get("/v1/files/#{file_id}/content")
      end
    end

    class FineTune < Resource
      def list
        Response::FineTuneList.from_json(
          get('/v1/fine-tunes')
        )
      end

      def create(training_file:, **)
        Response::FineTune.from_json(
          post('/v1/fine-tunes', training_file:, **)
        )
      end

      def fetch(fine_tune_id)
        Response::FineTune.from_json(
          get("/v1/fine-tunes/#{fine_tune_id}")
        )
      end

      def cancel(fine_tune_id)
        Response::FineTune.from_json(
          post("/v1/fine-tunes/#{fine_tune_id}/cancel")
        )
      end

      def list_events(fine_tune_id)
        Response::FineTuneEventList.from_json(
          get("/v1/fine-tunes/#{fine_tune_id}/events")
        )
      end
    end

    class Image < Resource
      def create(prompt:, **)
        Response::ImageGeneration.from_json(
          post('/v1/images/generations', prompt:, **)
        )
      end

      def create_variation(image:, **)
        Response::ImageVariation.from_json(
          post_form_multipart('/v1/images/variations', image: form_file(image), **)
        )
      end

      def edit(image:, prompt:, mask: nil, **kwargs)
        params = {
          image: form_file(image),
          prompt:,
          **kwargs
        }

        params[:mask] = form_file(mask) if mask

        Response::ImageEdit.from_json(
          post_form_multipart('/v1/images/edits', **params)
        )
      end
    end

    class Audio < Resource
      def speech(model:, input:, voice:, response_format: nil, **kwargs)
        payload = { model:, input:, voice: }
        payload[:response_format] = response_format if response_format
        payload.merge!(kwargs)
        response_format ||= 'mp3'

        audio_binary =
          client.raw_json_post('/v1/audio/speech', **payload)

        Response::Speech.new(
          format: response_format,
          data: audio_binary
        )
      end

      def transcribe(file:, model:, **)
        Response::Transcription.from_json(
          post_form_multipart(
            '/v1/audio/transcriptions',
            file: form_file(file),
            model:,
            **
          )
        )
      end

      def translate(file:, model:, **)
        Response::Transcription.from_json(
          post_form_multipart(
            '/v1/audio/translations',
            file: form_file(file),
            model:,
            **
          )
        )
      end
    end
  end
end
