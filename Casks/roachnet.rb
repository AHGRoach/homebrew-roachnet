cask "roachnet" do
  version "1.0.4"
  sha256 "1caf54cec6d475aa018afc0b8bbeafd71e0bce48c73bc09b3d449686b508ed03"

  url "https://github.com/AHGRoach/RoachNet/releases/download/v#{version}/RoachNet-Setup-macOS.dmg",
      verified: "github.com/AHGRoach/RoachNet/"
  name "RoachNet"
  desc "Local-first desktop command center for maps, models, dev tools, and your own notes"
  homepage "https://roachnet.org"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: ">= :sonoma"

  app "RoachNet Setup.app/Contents/Resources/InstallerAssets/RoachNet.app",
      target: "#{Dir.home}/RoachNet/app/RoachNet.app"

  postflight do
    require "json"
    require "shellwords"
    require "securerandom"
    require "time"

    install_root = File.join(Dir.home, "RoachNet")
    app_path = File.join(install_root, "app", "RoachNet.app")
    storage_path = File.join(install_root, "storage")
    local_bin_path = File.join(install_root, "bin")
    support_root = File.join(Dir.home, "Library", "Application Support", "roachnet")
    config_path = File.join(support_root, "roachnet-installer.json")
    legacy_config_path = File.join(Dir.home, ".roachnet-setup.json")
    timestamp = Time.now.utc.iso8601

    config = {
      "installPath" => install_root,
      "installedAppPath" => app_path,
      "storagePath" => storage_path,
      "useDockerContainerization" => false,
      "installRoachClaw" => true,
      "companionEnabled" => false,
      "companionHost" => "127.0.0.1",
      "companionPort" => 38111,
      "companionToken" => SecureRandom.hex(32),
      "companionAdvertisedURL" => "",
      "roachClawDefaultModel" => "qwen2.5-coder:1.5b",
      "distributedInferenceBackend" => "disabled",
      "exoBaseUrl" => "http://127.0.0.1:52415",
      "exoModelId" => "",
      "autoInstallDependencies" => false,
      "autoLaunch" => true,
      "releaseChannel" => "stable",
      "setupCompletedAt" => timestamp,
      "pendingLaunchIntro" => false,
      "pendingRoachClawSetup" => true,
    }

    FileUtils.mkdir_p(support_root)
    FileUtils.mkdir_p(storage_path)
    FileUtils.mkdir_p(local_bin_path)
    File.write(config_path, "#{JSON.pretty_generate(config)}\n")
    File.write(legacy_config_path, "#{JSON.pretty_generate(config)}\n")
    system "/bin/sh", "-c", "/usr/bin/xattr -cr #{Shellwords.escape(app_path)} >/dev/null 2>&1 || true"
  end

  zap trash: [
    "~/.roachnet-setup.json",
    "~/Library/Application Support/roachnet",
    "~/RoachNet",
  ]

  caveats do
    <<~EOS
      RoachNet installs into ~/RoachNet/app/RoachNet.app so the native app, vault, and local tools stay grouped together.

      Launch it with:
        open ~/RoachNet/app/RoachNet.app
    EOS
  end
end
