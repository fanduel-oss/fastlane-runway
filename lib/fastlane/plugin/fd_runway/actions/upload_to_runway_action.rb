require 'fastlane/action'

module Fastlane
  module Actions
    # Action to upload binaries to runway distribution
    class UploadToRunwayAction < Action
      def self.populate_ci_build_info_with_defaults(ci_build_info)
        new_ci_build_info = ci_build_info.dup
        if !ci_build_info.nil? && ci_build_info[:startedAt].nil?
          new_ci_build_info[:startedAt] = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
        end
        if !ci_build_info.nil? && ci_build_info[:status].nil?
          new_ci_build_info[:status] = 'success'
        end
        new_ci_build_info
      end

      def self.run(params)
        api_key = params[:api_key]
        app_id = params[:app_id]
        bucket_id = params[:bucket_id]
        file_path = params[:file_path]
        tester_notes = params[:tester_notes]
        ci_build_info = self.populate_ci_build_info_with_defaults(params[:ci_build_info])

        UI.user_error!("API Key is missing") unless api_key
        UI.user_error!("App ID is missing") unless app_id
        UI.user_error!("Bucket ID is missing") unless bucket_id
        UI.user_error!("File path is missing") unless file_path

        upload_url = "https://upload-api.runway.team/v1/app/#{app_id}/bucket/#{bucket_id}/build"

        response = Helper::FdRunwayHelper.upload_file(upload_url, api_key, file_path, tester_notes, ci_build_info)

        if response.success?
          UI.success("Successfully uploaded to Runway!")
        else
          raise "Failed to upload to Runway - upload failed. #{response.status}: #{response.body}"
        end
      end

      def self.is_supported?(platform)
        true
      end

      def self.description
        "Uploads a binary to Runway"
      end

      def self.authors
        ["Fanduel"]
      end

      def self.available_options # rubocop:disable Metrics/PerceivedComplexity
        [
          FastlaneCore::ConfigItem.new(
            key: :api_key,
            env_name: "RUNWAY_API_KEY",
            optional: false,
            type: String,
            description: "Your Runway API Key"
          ),
          FastlaneCore::ConfigItem.new(
            key: :app_id,
            optional: false,
            type: String,
            description: "The ID of your app in Runway"
          ),
          FastlaneCore::ConfigItem.new(
            key: :bucket_id,
            optional: false,
            type: String,
            description: "The ID of the bucket where you want to upload the app"
          ),
          FastlaneCore::ConfigItem.new(
            key: :file_path,
            optional: false,
            type: String,
            description: "Path to the APK/IPA file"
          ),
          FastlaneCore::ConfigItem.new(
            key: :tester_notes,
            optional: true,
            type: String,
            description: "Notes to attach to the build"
          ),
          FastlaneCore::ConfigItem.new(
            key: :ci_build_info,
            type: Hash,
            optional: true,
            description: "CI build information to display in runway",
            verify_block: proc do |value|
              if value
                UI.user_error!("ci_build_info must be a hash") unless value.kind_of?(Hash)
                UI.user_error!("ci_build_info must include buildIdentifier") unless value[:buildIdentifier]
                UI.user_error!("ci_build_info must include branch") unless value[:branch]
                UI.user_error!("ci_build_info must include integrationId. (\"appcenter-ci\" \"apple-ci\" \"azure-ci\" \"bitrise\" \"buildkite\" \"circleci\" \"codemagic\" \"generic-ci\" \"github-ci\" \"gitlab-ci\" \"jenkins\" \"travis\")") unless value[:integrationId]
                UI.user_error!("ci_build_info must include commitHash") unless value[:commitHash]
                UI.user_error!("ci_build_info must include workflowData") unless value[:workflowData]
                UI.user_error!("ci_build_info must include workflowData.workflowId") unless value[:workflowData][:workflowId]
                UI.user_error!("ci_build_info must include workflowData.workflowName") unless value[:workflowData][:workflowName]
              end
            end
          )
        ]
      end

      def self.example_code
        [
          'upload_to_runway(
              file_path: "./app.apk",
              bucket_id: "bucket_runwayId",
              app_id: "example-app",
              tester_notes: "This is a test upload!",
              ci_build_info: {
                buildIdentifier: "123",
                commitMessage: "some commit message",
                commitAuthor: "jp2014",
                branch: "main",
                integrationId: "azure-ci",
                commitHash: "1111111150d07ff3d2467e33aa118622909111111",
                commitUrl: "www.url-to-commit/xx",
                url: "www.url-to-build-integration",
                workflowData: {
                  workflowId: "7",
                  workflowName: "Main-CI"
                }
              }
          )',
          'upload_to_runway(
                file_path: "./app.apk",
                bucket_id: "bucket_runwayId",
                app_id: "example-app"
          )',
          'upload_to_runway(
                api_key: "your_api_key",
                file_path: "./app.apk",
                bucket_id: "bucket_runwayId",
                app_id: "example-app",
                tester_notes: "This is a test upload!"
          )'
        ]
      end
    end
  end
end
