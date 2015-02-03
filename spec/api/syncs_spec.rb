require "spec_helper"

describe "syncs" do
  let(:date) { Date.today.strftime("%Y-%m-%d") }
  let(:app) { Octodmin::App.new(File.expand_path("../..", __dir__)) }

  before do
    allow_any_instance_of(Git::Base).to receive(:pull).and_return(nil)
    allow_any_instance_of(Git::Base).to receive(:push).and_return(nil)
  end

  describe "create" do
    context "invalid" do
      before do
        allow_any_instance_of(Git::Base).to receive(:commit).and_raise(Git::GitExecuteError, "Git error")
        post "/api/syncs"
      end
      subject { parse_json(last_response.body)["errors"] }

      it "returns errors" do
        expect(last_response).to_not be_ok
        expect(subject.count).to eql(1)
        expect(subject.first).to eql("Git error")
      end
    end

    context "valid" do
      before do
        allow_any_instance_of(Git::Base).to receive(:commit).and_return(nil)

        # Create post
        post "/api/posts", title: "Yo"

        # Update post
        patch "/api/posts/2015-01-30-test", {
          layout: "post",
          title: "Test",
          date: "2015-01-30 18:10:00",
          content: "### WOW",
        }

        post "/api/syncs"
      end
      after do
        File.delete("sample/_posts/#{date}-yo.markdown")
        git = Git.open(Octodmin::App.dir)
        git.checkout("sample/_posts/2015-01-30-test.markdown")
      end
      subject { parse_json(last_response.body)["syncs"] }

      it "returns syncs" do
        expect(subject).to eql(["Octodmin sync for 2 files\n\n_posts/2015-02-03-yo.markdown\n_posts/2015-01-30-test.markdown"])
      end
    end
  end
end
