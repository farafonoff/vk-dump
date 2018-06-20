Hashie.logger = Logger.new(nil)
@config = YAML::load(File.read("config.yaml"))

API_VERSION = 5.74

VkontakteApi.configure { |config| config.api_version = API_VERSION.to_s }

SOURCE_FILES = Rake::FileList.new("internal/*yaml")
OUTPUT_FILES = Rake::FileList.new("output/*txt")

CLEAN.include(SOURCE_FILES)
CLOBBER.include(OUTPUT_FILES)