describe Fastlane::Actions::UploadToRunwayAction do
  describe '#run' do
    it 'raises an error if no api_key is given' do
      expect do
        Fastlane::Actions::UploadToRunwayAction.run({ app_id: 'app_id', bucket_id: 'bucket_id', file_path: 'file_path' })
      end.to raise_error("API Key is missing")
    end

    it 'raises an error if no app_id is given' do
      expect do
        Fastlane::Actions::UploadToRunwayAction.run({ api_key: 'api_key', bucket_id: 'bucket_id', file_path: 'file_path' })
      end.to raise_error("App ID is missing")
    end

    it 'raises an error if no bucket_id is given' do
      expect do
        Fastlane::Actions::UploadToRunwayAction.run({ api_key: 'api_key', app_id: 'app_id', file_path: 'file_path' })
      end.to raise_error("Bucket ID is missing")
    end

    it 'raises an error if no file_path is given' do
      expect do
        Fastlane::Actions::UploadToRunwayAction.run({ api_key: 'api_key', app_id: 'app_id', bucket_id: 'bucket_id' })
      end.to raise_error("File path is missing")
    end

    it 'raises an error if the upload fails' do
      allow(Fastlane::Helper::FdRunwayHelper).to receive(:upload_file).and_return({ "success" => false, "status" => 400, "error" => "Upload failed" })
      expect do
        Fastlane::Actions::UploadToRunwayAction.run({ api_key: 'api_key', app_id: 'app_id', bucket_id: 'bucket_id', file_path: 'file_path' })
      end.to raise_error("Failed to upload to Runway - upload failed. 400: Upload failed")
    end

    it 'prints a success message if the upload is successful' do
      allow(Fastlane::Helper::FdRunwayHelper).to receive(:upload_file).and_return({ "success" => true })
      expect(Fastlane::UI).to receive(:success).with("✅ Successfully uploaded to Runway!")
      Fastlane::Actions::UploadToRunwayAction.run({ api_key: 'api_key', app_id: 'app_id', bucket_id: 'bucket_id', file_path: 'file_path' })
    end

    it 'defaults startedAt to current time if not provided' do
      expect(Fastlane::Actions::UploadToRunwayAction.populate_ci_build_info_with_defaults({})[:startedAt]).to_not(be_nil)
    end

    it 'defaults status to success if not provided' do
      expect(Fastlane::Actions::UploadToRunwayAction.populate_ci_build_info_with_defaults({})[:status]).to eq('success')
    end

    it 'correctly transforms the download URL' do
      api_response = {
        "success" => true,
        "downloadUrl" => "/api/org/org_123/app/my-app/build-distribution/build/build_456/download?bucketId=bucket_789"
      }

      allow(Fastlane::Helper::FdRunwayHelper).to receive(:upload_file).and_return(api_response)

      expected_url = "https://app.runway.team/dashboard/org/org_123/app/my-app/builds?buildId=build_456&bucketId=bucket_789"

      expect(Fastlane::UI).to receive(:message).with("📥 Download URL: #{expected_url}")

      result = Fastlane::Actions::UploadToRunwayAction.run({
        api_key: 'api_key',
        app_id: 'app_id',
        bucket_id: 'bucket_id',
        file_path: 'file_path'
      })

      expect(result["downloadUrl"]).to eq(expected_url)
    end

    it 'falls back to raw download URL if transformation fails' do
      api_response = {
        "success" => true,
        "downloadUrl" => "/api/invalid-url-format"
      }

      allow(Fastlane::Helper::FdRunwayHelper).to receive(:upload_file).and_return(api_response)

      expect(Fastlane::UI).to receive(:message).with("📥 Download URL: /api/invalid-url-format")

      result = Fastlane::Actions::UploadToRunwayAction.run({
        api_key: 'api_key',
        app_id: 'app_id',
        bucket_id: 'bucket_id',
        file_path: 'file_path'
      })

      expect(result["downloadUrl"]).to eq("/api/invalid-url-format")
    end

    it 'handles missing download URL gracefully' do
      api_response = { "success" => true, "downloadUrl" => nil }

      allow(Fastlane::Helper::FdRunwayHelper).to receive(:upload_file).and_return(api_response)

      result = Fastlane::Actions::UploadToRunwayAction.run({
        api_key: 'api_key',
        app_id: 'app_id',
        bucket_id: 'bucket_id',
        file_path: 'file_path'
      })

      expect(result["downloadUrl"]).to be_nil
    end
  end
end
