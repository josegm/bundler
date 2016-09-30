# frozen_string_literal: true
require "spec_helper"

describe "bundle install with a lockfile present" do
  let(:gf) { <<-G }
    source "file://#{gem_repo1}"

    gem "rack", "1.0.0"
  G

  before do
    install_gemfile(gf)
  end

  context "gemfile evaluation" do
    let(:gf) { super() + "\n\n File.open('evals', 'a') {|f| f << %(1\n) } unless ENV['BUNDLER_SPEC_NO_APPEND']" }

    it "does not evaluate the gemfile twice" do
      bundle! :install

      with_env_vars("BUNDLER_SPEC_NO_APPEND" => "1") { should_be_installed "rack 1.0.0" }

      # The first eval is from the initial install, we're testing that the
      # second install doesn't double-eval
      expect(bundled_app("evals").read.lines.size).to eq(2)
    end

    context "when the gem is not installed" do
      before { FileUtils.rm_rf ".bundle" }

      it "does not evaluate the gemfile twice" do
        bundle! :install

        with_env_vars("BUNDLER_SPEC_NO_APPEND" => "1") { should_be_installed "rack 1.0.0" }

        # The first eval is from the initial install, we're testing that the
        # second install doesn't double-eval
        expect(bundled_app("evals").read.lines.size).to eq(2)
      end
    end
  end
end