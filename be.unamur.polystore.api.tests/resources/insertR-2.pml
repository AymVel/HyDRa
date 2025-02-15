conceptual schema conceptualSchema{

	entity type Actor {
		id : string,
		fullName : string,
		yearOfBirth : string,
		yearOfDeath : string
		identifier {
			id
		}
	}
	
	entity type Director {
		id : string,
		firstName : string,
		lastName : string,
		yearOfBirth : int,
		yearOfDeath : int
		identifier {
			id
		}
	}
	
	entity type Movie {
		id : string,
		primaryTitle : string,
		originalTitle : string,
		isAdult : bool,
		startYear : int,
		runtimeMinutes: int,
		averageRating : string,
		numVotes : int,
		dummy : string
		identifier{
			id
		}
	}
	
	entity type Review {
		id : string,
		content : string,
		note : int
		identifier {
			id
		}
	}
	
	entity type User {
		id : string,
		username : string,
		city : string
		identifier{
			id
		}
	}
	
	entity type Account {
		id: string,
		email : string,
		pass : string
		identifier{
			id
		}
	}
	
	relationship type userAccount {
		user[1] : User,
		account[1] : Account
	}
	   
    relationship type movieDirector{
		directed_movie[1]: Movie,
		director[0-N] : Director
	}
	relationship type movieActor{
		character[0-N]: Actor,
		movie[1-N] : Movie
	}
	relationship type movieReview{
		r_reviewed_movie[0-N]: Movie,
		r_review[1] : Review 
	}
	relationship type reviewUser{
		r_author[0-N]: User,
		r_review1[1] : Review
	}      
}
physical schemas { 
	
	document schema IMDB_Mongo : mymongo {
		collection userCol{
			fields {
				iduser,
				account[1]{
					idaccount,
					email
				}
			}
		}
		
		collection actorCol {
			fields{ 
				idactor,
				movies[0-N]{
					idmovie,
					reviews[0-N]{
						idreview,
						commenter[1]{
							iduser
						}
					}
				}
			}
		}		
	}
	
	relational schema myRelSchema : mydb{
		table directorTable {
			columns{
				id,
				fullname : [firstname]" "[lastname]
			}
		}
		
		table movieTable {
			columns{
				id,
				title,
				director_id
			}
			references{
				directorRef : director_id -> directorTable.id
			}
		}
	}
	
}
	

mapping rules{
	conceptualSchema.User(id) -> IMDB_Mongo.userCol(iduser),
	conceptualSchema.Account(id, email) -> IMDB_Mongo.userCol.account(idaccount, email),
	conceptualSchema.userAccount.user -> IMDB_Mongo.userCol.account(),
	
	conceptualSchema.Actor(id) -> IMDB_Mongo.actorCol(idactor),
	conceptualSchema.Movie(id) -> IMDB_Mongo.actorCol.movies(idmovie),
	conceptualSchema.Review(id) -> IMDB_Mongo.actorCol.movies.reviews(idreview),
	conceptualSchema.User(id) -> IMDB_Mongo.actorCol.movies.reviews.commenter(iduser),
	conceptualSchema.movieActor.character -> IMDB_Mongo.actorCol.movies(),
	conceptualSchema.movieReview.r_reviewed_movie -> IMDB_Mongo.actorCol.movies.reviews(),
	conceptualSchema.reviewUser.r_review1 -> IMDB_Mongo.actorCol.movies.reviews.commenter(),
	
	conceptualSchema.Director(id,firstName,lastName) -> myRelSchema.directorTable(id,firstname,lastname),
	conceptualSchema.Movie(id,primaryTitle) -> myRelSchema.movieTable(id,title),
	conceptualSchema.movieDirector.directed_movie -> myRelSchema.movieTable.directorRef
}

databases {
	
	mariadb mydb {
		host: "localhost"
		port: 3307
		dbname : "mydb"
		password : "password"
		login : "root"
	}
	
	mongodb mymongo{
		host : "localhost"
		port: 27100
	}
	
}