module Fastlane
  module Helper
    class FdRunwayHelper
      def self.upload_file(upload_url, api_key, file_path, tester_notes, ci_build_info)
        UI.message("Uploading file to Runway")

        connection = Faraday.new(url: upload_url) do |faraday|
          faraday.request(:multipart)
        end

        payload = {
          'file' => Faraday::UploadIO.new(file_path, 'application/octet-stream')
        }

        payload['data'] = { 'testerNotes' => tester_notes }.tap do |data|
          if ci_build_info
            data['ciBuildInfo'] = ci_build_info
          end
        end.to_json

        response = connection.post do |req|
          req.headers['X-API-KEY'] = api_key
          req.headers['Content-Type'] = 'multipart/form-data'
          req.body = payload
        end

        begin
          response_data = JSON.parse(response.body)
        rescue JSON::ParserError
          response_data = {}
        end

        response_data['success'] = response.status.between?(200, 299)
        response_data['status'] = response.status
        response_data
      end
    end
  end
end
