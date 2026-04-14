cask "roachnet" do
  local_dmg = ENV["ROACHNET_CASK_LOCAL_DMG"]
  local_sha = ENV["ROACHNET_CASK_LOCAL_SHA"]

  version "1.0.2"
  sha256 local_dmg.to_s.empty? ? "7dff40f41bfb0b6d05fbcbe8f5804421257e9659ac326dc6efc6b99cb2996f63" : local_sha

  url local_dmg.to_s.empty? ? "https://github.com/AHGRoach/RoachNet/releases/download/v#{version}/RoachNet-Setup-macOS.dmg" : "file://#{local_dmg}",
      verified: local_dmg.to_s.empty? ? "github.com/AHGRoach/RoachNet/" : nil
  name "RoachNet"
  desc "Local-first desktop command center for maps, models, dev tools, and your own notes"
  homepage "https://roachnet.org"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: ">= :sonoma"

  app "RoachNet.app",
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
    embedded_node = File.join(app_path, "Contents", "Resources", "EmbeddedRuntime", "node", "bin", "node")
    roachtail_alias_installer = File.join(app_path, "Contents", "Resources", "RoachNetSource", "scripts", "install-roachtail-hostname.mjs")
    timestamp = Time.now.utc.iso8601

    config = {
      "installPath" => install_root,
      "installedAppPath" => app_path,
      "storagePath" => storage_path,
      "installProfile" => "homebrew-cask",
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
      "bootstrapPending" => true,
      "bootstrapFailureCount" => 0,
      "lastRuntimeHealthAt" => nil,
      "pendingLaunchIntro" => false,
      "pendingRoachClawSetup" => true,
    }

    FileUtils.mkdir_p(support_root)
    FileUtils.mkdir_p(storage_path)
    FileUtils.mkdir_p(local_bin_path)
    File.write(config_path, "#{JSON.pretty_generate(config)}\n")
    File.write(legacy_config_path, "#{JSON.pretty_generate(config)}\n")
    system "/bin/sh", "-c", "/usr/bin/xattr -d com.apple.quarantine #{Shellwords.escape(app_path)} >/dev/null 2>&1 || true"
    system "/bin/sh", "-c", "/usr/bin/xattr -d com.apple.provenance #{Shellwords.escape(app_path)} >/dev/null 2>&1 || true"
    system "/bin/sh", "-c", "/usr/bin/xattr -cr #{Shellwords.escape(app_path)} >/dev/null 2>&1 || true"
    if File.exist?(embedded_node) && File.exist?(roachtail_alias_installer)
      system(
        {
          "ROACHNET_LOCAL_HOSTNAME" => "RoachNet",
        },
        embedded_node,
        roachtail_alias_installer,
        "--interactive"
      )
    end
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
