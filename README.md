# fd_runway plugin

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin.

If you aren't setup with fastlane yet, you'll need to get your project setup before proceeding.


Run this command to install the plugin.
```bash
bundle exec fastlane add_plugin fd_runway
```

For now, this plugin is only available through fanduel-oss github. Select Git URL Paste the ssh address: `git@github.com:fanduel-oss/fastlane-runway.git` The plugin should install automatically. If not, you can run bundle install to do it manually. Distribution through rubygems is pending FanDuel review.

Add a lane in your Fastfile for using the plugin.
```bash
 lane :upload_runway do
        upload_to_runway(
          api_key: 'RUNWAY_API_KEY', # or add `RUNWAY_API_KEY` to your environment
          file_path: 'path_to_file', #apk or ipa file path
          bucket_id: 'runway_bucket_id',
          app_id: 'runway_app_id',
          tester_notes: 'This is a test upload' #optional - shows tester notes in the Runway console
          ci_build_info: { #optional - shows some nice information in the Runway console
            buildIdentifier: "123",
            commitMessage: "some commit message",
            commitAuthor: "jp2014",
            branch: "main",
            integrationId: "azure-ci",
            commitHash: "1111111150d07ff3d2467e33aa118622909111111",
            workflowData: {
              workflowId: "7",
              workflowName: "Main-CI"
            }
          }
        )
 end
```


## About fd_runway

A wrapper around the runway distribution[ upload apis](https://api-docs.runway.team/#tag/buildDistro/operation/uploadBucketBuild).

## Example

See fastlane/Fastfile for an example of how to use this plugin. That Fastfile can also be used for testing during development.

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
