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
      allow(Fastlane::Helper::FdRunwayHelper).to receive(:upload_file).and_return(double(success?: false, body: 'error'))
      expect do
        Fastlane::Actions::UploadToRunwayAction.run({ api_key: 'api_key', app_id: 'app_id', bucket_id: 'bucket_id', file_path: 'file_path' })
      end.to raise_error("Failed to upload to Runway - upload failed")
    end

    it 'prints a success message if the upload is successful' do
      allow(Fastlane::Helper::FdRunwayHelper).to receive(:upload_file).and_return(double(success?: true))
      expect(Fastlane::UI).to receive(:success).with("Successfully uploaded to Runway!")
      Fastlane::Actions::UploadToRunwayAction.run({ api_key: 'api_key', app_id: 'app_id', bucket_id: 'bucket_id', file_path: 'file_path' })
    end

    it 'defaults startedAt to current time if not provided' do
      expect(Fastlane::Actions::UploadToRunwayAction.populate_ci_build_info_with_defaults({})[:startedAt]).to_not(be_nil)
    end

    it 'defaults status to success if not provided' do
      expect(Fastlane::Actions::UploadToRunwayAction.populate_ci_build_info_with_defaults({})[:status]).to eq('success')
    end

    # TODO: Add more tests
  end
end
