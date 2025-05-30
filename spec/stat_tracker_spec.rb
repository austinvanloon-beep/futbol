require 'spec_helper'

RSpec.describe StatTracker do

    describe '#initialize' do

        it 'creates instance variables for games, teams, and game_teams' do
            # I think mocking the output here is necessary based on the size/row count of each .csv file
            # so this is how I did it for now but we can discuss still! I read something about "fixtures" that seem similar
            mock_games = double('games')
            mock_teams = double('teams')
            mock_game_teams = double('game_teams')

            stat_tracker = StatTracker.new(mock_games, mock_teams, mock_game_teams)

            expect(stat_tracker.instance_variable_get(:@games)).to eq(mock_games)
            expect(stat_tracker.instance_variable_get(:@teams)).to eq(mock_teams)
            expect(stat_tracker.instance_variable_get(:@game_teams)).to eq(mock_game_teams)
        end
    end

    describe '#.from_csv' do
            
        it 'returns a StatTracker with loaded game, team, and game_team data' do
          
            locations = {
            games: './data/games.csv',
            teams: './data/teams.csv',
            game_teams: './data/game_teams.csv'
            }
          
          stat_tracker = StatTracker.from_csv(locations)
      
          expect(stat_tracker).to be_a(StatTracker)
          
        end
    end

    #Game Statistics - Will

    describe 'calculate game statistics' do

        let(:locations) do {
              games: './spec/fixtures/games_fixture.csv',
              teams: './spec/fixtures/teams_fixture.csv',
              game_teams: './spec/fixtures/game_teams_fixture.csv'
            }
          end
        
        let(:stat_tracker) { StatTracker.from_csv(locations) }

        it "can calculate highest sum of the winning and losing teams scores" do

           expect(stat_tracker.highest_total_score).to eq(7) # 6+1 = 7 in Game 1
        
        end

        it "can calculate lowest sum of the winning and losing teams scores" do
            expect(stat_tracker.lowest_total_score).to eq(1) # 
        end

        it "can calculate the percentage of games that a home team has won (rounded to the nearest 100th)" do
            expect(stat_tracker.percentage_home_wins).to eq(0.6)
        end

        it "can calculate the percentage of games that a visitor has won (rounded to the nearest 100th)" do
            expect(stat_tracker.percentage_visitor_wins).to eq(0.2)
        end

        it "can calculate the percentage of games that has resulted in a tie (rounded to the nearest 100th)" do
            expect(stat_tracker.percentage_ties).to eq(0.2)
        end

        it "can store games by season" do
            expect(stat_tracker.count_of_games_by_season).to eq({
            "20122013" => 4,
            "20132014" => 1
            })
        end

        it "can average goals per game" do 
            expect(stat_tracker.average_goals_per_game).to eq(4)
        end

        it 'can average goals per game per season' do
            expect(stat_tracker.average_goals_by_season).to eq({
                "20122013" => 4.0,
                "20132014" => 4.0
            })
        end
    end
    
    #League Statistics - Austin
    # fill in if time
    describe 'calculate league statistics' do
        
        let(:locations) do {
              games: './spec/fixtures/games_fixture.csv',
              teams: './spec/fixtures/teams_fixture.csv',
              game_teams: './spec/fixtures/game_teams_fixture.csv'
            }
          end
        
        let(:stat_tracker) { StatTracker.from_csv(locations) }
    
        it "#best_offense" do
            expect(stat_tracker.best_offense).to eq("Team Three")
        end
        
        it "#worst_offense" do
            expect(stat_tracker.worst_offense).to eq("Team Two")
        end
        
        it "#highest_scoring_visitor" do
            expect(stat_tracker.highest_scoring_visitor).to eq("Team Three")
        end
        
        it "#highest_scoring_home_team" do
            expect(stat_tracker.highest_scoring_home_team).to eq("Team Six")
        end
        
        it "#lowest_scoring_visitor" do
            expect(stat_tracker.lowest_scoring_visitor).to eq("Team Two")
        end
        
        it "#lowest_scoring_home_team" do
            expect(stat_tracker.lowest_scoring_home_team).to eq("Team Four")
        end
        
        it "#count_of_teams" do
            expect(stat_tracker.count_of_teams).to eq 6
        end
    end

    #Season Statistics - Nick
    describe 'calculate season statistics' do

        let(:locations) do {
              games: './spec/fixtures/games_fixture.csv',
              teams: './spec/fixtures/teams_fixture.csv',
              game_teams: './spec/fixtures/game_teams_fixture.csv'
            }
          end
        
        let(:stat_tracker) { StatTracker.from_csv(locations) }

        describe '#game_team_seasons' do

            it 'returns an array of GameTeam objects for the given season' do
                expected = stat_tracker.game_team_seasons("20122013")
            
                expected.each do |game_team_row|

                expect(game_team_row).to be_a(GameTeam)
                expect(expected.class).to eq(Array)
                end
            end

            it 'returns the correct number of GameTeam rows for the season 20122013' do
                expected = stat_tracker.game_team_seasons("20122013")
            
                # There are 4 games in 20122013 in the fixture, each with 2 teams
                expect(expected.length).to eq(8)
            end

            it 'does not include GameTeam rows from any other season' do
                expected = stat_tracker.game_team_seasons("20122013")
            
                expected.each do |game_team_row|
                    matching_game = stat_tracker.games.find do |game| 
                        game.game_id == game_team_row.game_id
                    end
            
                    expect(matching_game).not_to be_nil
                    expect(matching_game.season).to eq("20122013")
                end
              end

            it 'returns an empty array if no games exist for the given season' do
                expected = stat_tracker.send(:game_team_seasons, "19999999")
            
                expect(expected).to eq([])
            end
        end

        it 'returns the coach with the best win percentage for the season' do
            
            # Expected coach_records hash after filtering by for the 20122013 season:
            
            # {
            #   "Coach A" => { wins: 0, total: 3 },
            #   "Coach B" => { wins: 3, total: 3 },
            #   "Coach C" => { wins: 1, total: 2 }
            # }
            
            expect(stat_tracker.winningest_coach("20122013")).to eq("Coach B")
        end

        it '#worst_coach' do
            
            # Expected coach_records hash after filtering by for the 20122013 season:
            
            # {
            #   "Coach A" => { wins: 0, total: 3 },
            #   "Coach B" => { wins: 3, total: 3 },
            #   "Coach C" => { wins: 1, total: 2 }
            # }

            expect(stat_tracker.worst_coach("20122013")).to eq("Coach A")
        end

        it '#most_accurate_team' do
            
            # Expected team_accuracy_data hash after filtering for just the 20122013 season:
            
            # {
            #   "Team One" => { goals: 5, shots: 28 },
            #   "Team Two" => { goals: 0, shots: 11 },
            #   "Team Three" => { goals: 6, shots: 22 },
            #   "Team Four" => { goals: 1, shots: 16 },
            #   "Team Five" => { goals: 1, shots: 12 },
            #   "Team Six" => { goals: 3, shots: 14 }
            # }

            expect(stat_tracker.most_accurate_team("20122013")).to eq("Team Three")
        end

        it '#least_accurate_team' do

           # Expected team_accuracy_data hash after filtering for just the 20122013 season:
            
            # {
            #   "Team One" => { goals: 5, shots: 28 },
            #   "Team Two" => { goals: 0, shots: 11 },
            #   "Team Three" => { goals: 6, shots: 22 },
            #   "Team Four" => { goals: 1, shots: 16 },
            #   "Team Five" => { goals: 1, shots: 12 },
            #   "Team Six" => { goals: 3, shots: 14 }
            # }
        
            expect(stat_tracker.least_accurate_team("20122013")).to eq("Team Two")
        end

        it '#most_tackles' do

           # Expected team_tackles_data hash after filtering for just the 20122013 season:
            
           # {
            #   "Team One" => { tackles: 13 },
            #   "Team Two" => { tackles: 5 },
            #   "Team Three" => { tackles: 9 },
            #   "Team Four" => { tackles: 9 },
            #   "Team Five" => { tackles: 6 },
            #   "Team Six" => { tackles: 8 }
            # }

            expect(stat_tracker.most_tackles("20122013")).to eq("Team One")
        end

        it '#fewest_tackles' do
            
            # Expected team_tackles_data hash after filtering for just the 20122013 season:
            
           # {
            #   "Team One" => { tackles: 13 },
            #   "Team Two" => { tackles: 5 },
            #   "Team Three" => { tackles: 9 },
            #   "Team Four" => { tackles: 9 },
            #   "Team Five" => { tackles: 6 },
            #   "Team Six" => { tackles: 8 }
            # }

            expect(stat_tracker.fewest_tackles("20122013")).to eq("Team Two")

        end
    end

    
      
    describe 'spec_harness results' do

        before(:all) do
            
            game_path = './data/games.csv'
            team_path = './data/teams.csv'
            game_teams_path = './data/game_teams.csv'

            locations = {
            games: game_path,
            teams: team_path,
            game_teams: game_teams_path
            }

            @stat_tracker = StatTracker.from_csv(locations)
        end
        
        #Game Statistics - Will

        it 'exists' do
            expect(@stat_tracker).to be_an_instance_of StatTracker
        end

        it '#highest_total_score' do
            expect(@stat_tracker.highest_total_score).to eq 11
        end
    
        it '#lowest_total_score' do
            expect(@stat_tracker.lowest_total_score).to eq 0
        end
    
        it '#percentage_home_wins' do
            expect(@stat_tracker.percentage_home_wins).to eq 0.44
        end
    
        it '#percentage_visitor_wins' do
            expect(@stat_tracker.percentage_visitor_wins).to eq 0.36
        end
    
        it '#percentage_ties' do
            expect(@stat_tracker.percentage_ties).to eq 0.20
        end
    
        it '#count_of_games_by_season' do
        
            expected = {
                "20122013"=>806,
                "20162017"=>1317,
                "20142015"=>1319,
                "20152016"=>1321,
                "20132014"=>1323,
                "20172018"=>1355
            }

            expect(@stat_tracker.count_of_games_by_season).to eq expected
        end

        it '#average_goals_per_game' do
            expect(@stat_tracker.average_goals_per_game).to eq 4.22
        end
    
        it '#average_goals_by_season' do
            expected = {
                "20122013"=>4.12,
                "20162017"=>4.23,
                "20142015"=>4.14,
                "20152016"=>4.16,
                "20132014"=>4.19,
                "20172018"=>4.44
            }
            expect(@stat_tracker.average_goals_by_season).to eq expected
        end
    

        # League Statistics - Austin

        describe 'League Statistics' do

            it "#count_of_teams" do
            expect(@stat_tracker.count_of_teams).to eq 32
            end
        
            it "#best_offense" do
            expect(@stat_tracker.best_offense).to eq "Reign FC"
            end
        
            it "#worst_offense" do
            expect(@stat_tracker.worst_offense).to eq "Utah Royals FC"
            end
        
            it "#highest_scoring_visitor" do
            expect(@stat_tracker.highest_scoring_visitor).to eq "FC Dallas"
            end
        
            it "#highest_scoring_home_team" do
            expect(@stat_tracker.highest_scoring_home_team).to eq "Reign FC"
            end
        
            it "#lowest_scoring_visitor" do
            expect(@stat_tracker.lowest_scoring_visitor).to eq "San Jose Earthquakes"
            end
        
            it "#lowest_scoring_home_team" do

            expect(@stat_tracker.lowest_scoring_home_team).to eq "Utah Royals FC"
            end
        end

        # season statistics - Nick
        describe 'season statistics' do

        it '#winningest_coach' do
            expect(@stat_tracker.winningest_coach("20132014")).to eq "Claude Julien"
            expect(@stat_tracker.winningest_coach("20142015")).to eq "Alain Vigneault"
        end

        it '#worst_coach' do
            expect(@stat_tracker.worst_coach("20132014")).to eq "Peter Laviolette"
            expect(@stat_tracker.worst_coach("20142015")).to eq("Craig MacTavish").or(eq("Ted Nolan"))
        end

        it '#most_accurate_team' do
            expect(@stat_tracker.most_accurate_team("20132014")).to eq "Real Salt Lake"
            expect(@stat_tracker.most_accurate_team("20142015")).to eq "Toronto FC"
        end

        it '#least_accurate_team' do
            expect(@stat_tracker.least_accurate_team("20132014")).to eq "New York City FC"
            expect(@stat_tracker.least_accurate_team("20142015")).to eq "Columbus Crew SC"
        end

        it '#most_tackles' do
            expect(@stat_tracker.most_tackles("20132014")).to eq "FC Cincinnati"
            expect(@stat_tracker.most_tackles("20142015")).to eq "Seattle Sounders FC"
        end

        it '#fewest_tackles' do
            expect(@stat_tracker.fewest_tackles("20132014")).to eq "Atlanta United"
            expect(@stat_tracker.fewest_tackles("20142015")).to eq "Orlando City SC"
        end
    end
        
    # skipping Iteration 4 stuff

        xit "#team_info" do
            expected = {
            "team_id" => "18",
            "franchise_id" => "34",
            "team_name" => "Minnesota United FC",
            "abbreviation" => "MIN",
            "link" => "/api/v1/teams/18"
            }

            expect(@stat_tracker.team_info("18")).to eq expected
        end

        xit "#best_season" do
            expect(@stat_tracker.best_season("6")).to eq "20132014"
        end

        xit "#worst_season" do
            expect(@stat_tracker.worst_season("6")).to eq "20142015"
        end

        xit "#average_win_percentage" do
            expect(@stat_tracker.average_win_percentage("6")).to eq 0.49
        end

        xit "#most_goals_scored" do
            expect(@stat_tracker.most_goals_scored("18")).to eq 7
        end

        xit "#fewest_goals_scored" do
            expect(@stat_tracker.fewest_goals_scored("18")).to eq 0
        end

        xit "#favorite_opponent" do
            expect(@stat_tracker.favorite_opponent("18")).to eq "DC United"
        end

        xit "#rival" do
            expect(@stat_tracker.rival("18")).to eq("Houston Dash").or(eq("LA Galaxy"))
        end
    end


end