#--------------------------------------------
# do some more munging on reg.game
#--------------------------------------------

# backup copy before munging
reg.backup <- reg.game

# if necessary use backup to debug code below
#reg.game <- reg.backup

# delete row with home.team = "Eastern Conf" since I don't care about allstar game 
# X[ ! X$Variable1 %in% c(11,12), ]
reg.game <- reg.game[ ! reg.game$home.team=="Eastern Conf",]

# remove records with missing game_id
reg.game <- reg.game[!is.na(reg.game$game.id),]


#subset(reg.game, subset=(home.team == ""))
#subset(reg.game, subset=(away.team == ""))

# remove any observations with away.team = missing
reg.game <- reg.game[reg.game$away.team != "",]


# get year and game number from game.id
reg.game$game.id2  <- str_trim(reg.game$game.id, side="both")

reg.game$year <- as.integer(substr(x=reg.game$game.id2, start=1, stop=4))
reg.game$game.number <- as.integer(substr(x=reg.game$game.id2, start=5, stop=8))

reg.game$era.ind <- ifelse(reg.game$year > 2003, 
                            "post-lockout",
                            "pre-lockout")

# convert attendance numbers that have embedded comma to a numeric value
reg.game$attendance <- as.numeric(gsub(",", "", reg.game$attendance))

# compute total goals scored
reg.game$home.goals <- as.numeric(reg.game$home.goals)
reg.game$away.goals <- as.numeric(reg.game$away.goals)
reg.game$total.goals <- reg.game$home.goals + reg.game$away.goals

# derive whether home team or away team won the game
reg.game$winner <- ifelse(reg.game$home.goals > reg.game$away.goals,
                          "home",
                          "away")


# use custom recodeteam function to recode messy team names
new.home.team.names <- recodeteam(reg.game$home.team)
new.away.team.names <- recodeteam(reg.game$away.team)

reg.game$home.team.long <- new.home.team.names$team.long
reg.game$home.team.short <- new.home.team.names$team.short

reg.game$away.team.long <- new.away.team.names$team.long
reg.game$away.team.short <- new.away.team.names$team.short



reg.game$home.conference <- recode(reg.game$home.team.long,
                                   "c('Anaheim Ducks', 'Calgary Flames', 'Chicago Blackhawks', 'Colorado Avalanche', 
                                     'Columbus Blue Jackets', 'Dallas Stars', 'Detroit Red Wings', 'Edmonton Oilers',
                                   'Los Angeles Kings', 'Minnesota Wild', 'Nashville Predators', 'Phoenix Coyotes',
                                   'San Jose Sharks', 'St Louis Blues', 'Vancouver Canucks', 'Winnipeg Jets') = 'West';
                                   c('Atlanta Thrashers', 'Boston Bruins', 'Buffalo Sabres', 'Carolina Hurricanes', 'Florida Panthers', 
                                   'Hartford Whalers', 'Montreal Canadiens', 'New Jersey Devils', 'New York Islanders', 'New York Rangers',
                                   'Ottawa Senators', 'Philadelphia Flyers', 'Pittsburgh Penguins', 'Quebec Nordiques', 'Tampa Bay Lightning',
                                   'Toronto Maple Leafs', 'Washington Capitals') = 'East'",
                                  as.factor.result=TRUE)

reg.game$away.conference <- recode(reg.game$away.team.long,
                                   "c('Anaheim Ducks', 'Calgary Flames', 'Chicago Blackhawks', 'Colorado Avalanche', 
                                     'Columbus Blue Jackets', 'Dallas Stars', 'Detroit Red Wings', 'Edmonton Oilers',
                                   'Los Angeles Kings', 'Minnesota Wild', 'Nashville Predators', 'Phoenix Coyotes',
                                   'San Jose Sharks', 'St Louis Blues', 'Vancouver Canucks', 'Winnipeg Jets') = 'West';
                                   c('Atlanta Thrashers', 'Boston Bruins', 'Buffalo Sabres', 'Carolina Hurricanes' , 'Florida Panthers', 
                                   'Hartford Whalers', 'Montreal Canadiens', 'New Jersey Devils', 'New York Islanders', 'New York Rangers',
                                   'Ottawa Senators', 'Philadelphia Flyers', 'Pittsburgh Penguins', 'Quebec Nordiques', 'Tampa Bay Lightning',
                                   'Toronto Maple Leafs', 'Washington Capitals') = 'East'",
                                  as.factor.result=TRUE)

reg.game$matchup.conference <- ifelse(reg.game$away.conference == "West" & reg.game$home.conference == "West",
                                      "West",
                                      ifelse(reg.game$away.conference == "East" & reg.game$home.conference == "East",
                                             "East",
                                             "Other"))

# remove variables that aren't needed anymore
reg.game$home.team <- reg.game$away.team <- reg.game$game.id2 <- NULL

# save into a workspace using cache
cache("reg.game")