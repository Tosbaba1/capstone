require "zlib"

class FeatureFlags
  CONFIG_PATH = Rails.root.join("config/experiments.yml")

  def self.config
    @config ||= begin
      raw_config = YAML.load_file(CONFIG_PATH)
      default_config = raw_config.fetch("default", {})
      env_config = raw_config.fetch(Rails.env, {})

      default_config.deep_merge(env_config)
    end
  end

  def initialize(user:)
    @user = user
  end

  def assignments
    @assignments ||= {
      session_type: session_type,
      session_length: session_length,
      presence_visibility: presence_visibility
    }
  end

  def session_type
    variant_for(:session_type)
  end

  def session_length
    variant_for(:session_length).to_i
  end

  def presence_visibility
    variant_for(:presence_visibility)
  end

  private

  attr_reader :user

  def variant_for(flag_name)
    definition = self.class.config.fetch(flag_name.to_s)
    variants = definition.fetch("variants")

    return definition.fetch("default") if user.blank?

    variants[bucket_index(flag_name, variants.length)]
  end

  def bucket_index(flag_name, size)
    Zlib.crc32("#{flag_name}:#{user.id}") % size
  end
end
