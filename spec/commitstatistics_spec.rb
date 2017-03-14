
require 'codespicuous'

describe "Team commits per week table" do

  participants = Participants.new
  bas = Participant.new "basvodde"
  bas.team = "Wine"
  participants.add bas

  daniel =  Participant.new "daniel"
  daniel.team = "Cheese"
  participants.add daniel

  janne = Participant.new "janne"
  janne.team = "Wine"
  participants.add janne

  commits = Commits.new
  commits.add Commit.new( { :revision => 42, :author => "basvodde", :date => DateTime.parse("2016-04-17"), :repository => "osaka" } )
  commits.add Commit.new( { :revision => 43, :author => "basvodde", :date => DateTime.parse("2016-04-18"), :repository => "osaka" } )
  commits.add Commit.new( { :revision => 44, :author => "basvodde", :date => DateTime.parse("2016-05-01"), :repository => "osaka" } )
  commits.add Commit.new( { :revision => 45, :author => "basvodde", :date => DateTime.parse("2016-05-01"), :repository => "osaka" } )
  commits.add Commit.new( { :revision => 46, :author => "basvodde", :date => DateTime.parse("2016-03-13"), :repository => "osaka" } )
  commits.add Commit.new( { :revision => 47, :author => "basvodde", :date => DateTime.parse("2016-03-13"), :repository => "osaka" } )
  commits.add Commit.new( { :revision => 48, :author => "basvodde", :date => DateTime.parse("2016-03-15"), :repository => "osaka" } )
  commits.add Commit.new( { :revision => 49, :author => "basvodde", :date => DateTime.parse("2016-03-13"), :repository => "osaka" } )
  commits.add Commit.new( { :revision => 50, :author => "basvodde", :date => DateTime.parse("2016-04-03"), :repository => "osaka" } )
  commits.add Commit.new( { :revision => 51, :author => "daniel",   :date => DateTime.parse("2016-03-27"), :repository => "osaka" } )
  commits.add Commit.new( { :revision => 52, :author => "janne",    :date => DateTime.parse("2016-02-28"), :repository => "cpputest" } )
  commits.add Commit.new( { :revision => 53, :author => "janne",    :date => DateTime.parse("2016-04-03"), :repository => "cpputest" } )
  commits.add Commit.new( { :revision => 54, :author => "janne",    :date => DateTime.parse("2016-04-03"), :repository => "cpputest" } )
  commits.add Commit.new( { :revision => 55, :author => "janne",    :date => DateTime.parse("2016-04-03"), :repository => "cpputest" } )
  commits.add Commit.new( { :revision => 56, :author => "janne",    :date => DateTime.parse("2016-05-15"), :repository => "cpputest" } )
  commits.add Commit.new( { :revision => 57, :author => "janne",    :date => DateTime.parse("2016-05-15"), :repository => "cpputest" } )
  commits.add Commit.new( { :revision => 58, :author => "janne",    :date => DateTime.parse("2016-05-15"), :repository => "cpputest" } )

  subject { CommitStatistics.new(commits, participants) }

  it "calculates the amount of committers" do
    expect(subject.amount_of_comitters).to eq(3)
  end

  it "knows the team the person is in" do
    expect(subject.committer("basvodde").team).to eq "Wine"
  end

  it "can extract the commit amounts per user per week" do
    expect(subject.committer("basvodde").amount_of_weeks_committed_to_repository("osaka")).to eq 4
  end

  it "can extract the commits per user" do
    expect(subject.committer("basvodde").amount_of_commits_to_repository_in_week("osaka", DateTime.new(2016,03,13))).to eq 4
    expect(subject.committer("basvodde").amount_of_commits_to_repository_in_week("osaka", DateTime.new(2016,04,17))).to eq 2
  end

  it "should be able to extract all the repositories" do
    expect(subject.repositories_committed_to).to include "osaka"
  end

  it "should be able to extract all the teams" do
    expect(subject.teams).to eq ["Cheese", "Wine"]
  end

  it "Should be able to create the wonderful table (sorted on team)" do
    table = "Committer,Team,osaka,cpputest,Total
daniel,Cheese,1,0,1
basvodde,Wine,9,0,9
janne,Wine,0,7,7
"
    expect(subject.create_commit_table_with_committers_and_repository_info).to eq table
  end

  it "should be able to find the earliest commit date" do
    expect(subject.first_week_committed).to eq DateTime.new(2016,02,28)
  end

  it "should be able to find the latest commit date" do
    expect(subject.last_week_committed).to eq DateTime.new(2016,05,15)
  end

  it "Should be able to get the amount of commits per team per week without commits" do
    expect(subject.amount_of_commits_for_team_in_week("Cheese", "2016-01-01")).to eq 0
  end

  it "Should be able to get the amount of commits per team per week" do
    expect(subject.amount_of_commits_for_team_in_week("Cheese", DateTime.new(2016,03,27))).to eq 1
  end

  it "Should make a time table with commits and team" do
    table = "Week,Cheese,Wine
2016-02-28,0,1
2016-03-06,0,0
2016-03-13,0,4
2016-03-20,0,0
2016-03-27,1,0
2016-04-03,0,4
2016-04-10,0,0
2016-04-17,0,2
2016-04-24,0,0
2016-05-01,0,2
2016-05-08,0,0
2016-05-15,0,3
"
    expect(subject.create_commit_table_with_weeks_and_team_commits).to eq table
  end

  it "Should make a time table with commits per repository" do
    table = "Week,osaka,cpputest
2016-02-28,0,1
2016-03-06,0,0
2016-03-13,4,0
2016-03-20,0,0
2016-03-27,1,0
2016-04-03,1,3
2016-04-10,0,0
2016-04-17,2,0
2016-04-24,0,0
2016-05-01,2,0
2016-05-08,0,0
2016-05-15,0,3
"
    expect(subject.create_commit_table_with_week_and_repository_info).to eq table
  end

  it "Should make a time table with commits per user" do
    table = "Week,basvodde,daniel,janne
2016-02-28,0,0,1
2016-03-06,0,0,0
2016-03-13,4,0,0
2016-03-20,0,0,0
2016-03-27,0,1,0
2016-04-03,1,0,3
2016-04-10,0,0,0
2016-04-17,2,0,0
2016-04-24,0,0,0
2016-05-01,2,0,0
2016-05-08,0,0,0
2016-05-15,0,0,3
"
    expect(subject.create_commit_table_with_weeks_and_committers).to eq table
  end

  it "Should make a time table with commits per user in team" do
    table = "Week,basvodde,janne
2016-02-28,0,1
2016-03-06,0,0
2016-03-13,4,0
2016-03-20,0,0
2016-03-27,0,0
2016-04-03,1,3
2016-04-10,0,0
2016-04-17,2,0
2016-04-24,0,0
2016-05-01,2,0
2016-05-08,0,0
2016-05-15,0,3
"
    expect(subject.create_commit_table_with_weeks_and_committers("Wine")).to eq table
  end
end

