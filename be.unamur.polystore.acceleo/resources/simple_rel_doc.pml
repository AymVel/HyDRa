conceptual schema cs {
	entity type Product{
		id:string,
		name:string,
		price:float,
		description:string,
		cat_name : string,
		cat_description: string

		identifier{
			id
		}
	}
	
	entity type Client{
		clientnumber : int, 
		lastname : string,
		firstname : string,
		age: int
		
		identifier{
			clientnumber
		}
		
	} 
	
	entity type Review {
		id : string,
		rating : int,
		content : string
	}
	
	
	entity type Comment {
		comment : string,
		number : int // should be the nmber of the comment on the review (incremental)
	}
	
	relationship type productReview{
	reviews[1]: Review,
	product[0-N] : Product,
	review_date : date
	}
	
	relationship type commentReview {
		review[0-N]: Review, 
		comments[1]: Comment
	}
}
physical schemas {
	document schema myDocSchema : mymongo{
		collection product_reviews{
			fields { 
				id,
				product_ref,
				productDescription,
				productprice, // A renommer 'price'
				productname, // A renommer en 'name' quand test sur EmbeddedObject done
				reviews[0-N]{
					fake_nested [0-N]{
						fakeAtt,
						product_attributes [1] {
							name,
							price : [prices]"$"						
							}
					},
					userid,
					numberofstars:[rate],
					ratingstring :[rate2]"*",
					title,
					content,
					comments[0-N]{
						comment,
						number
					}
				},
				category [1] {
					category_name,
					category_description
				}
			}
		}
	}
	
	relational schema myRelSchema : myMariaDB, mysqlite {
		table Customer {
			columns {
				clientnumber,
				fullname:[firstName]" "[lastName],
				age:[age]" years old"
			}
		}
	}
}
	
mapping rules{
	cs.Product(id,description/*,name,price*/) -> myDocSchema.product_reviews(product_ref,productDescription/*,name,price*/), // Commenter pour tester les EmbeddedObject Acceleo..
	cs.Product(cat_name, cat_description) -> myDocSchema.product_reviews.category(category_name, category_description ),
	cs.productReview.reviews -> myDocSchema.product_reviews.reviews(),
	cs.Product(name,price) -> myDocSchema.product_reviews.reviews.fake_nested.product_attributes(name,prices),
	cs.Review(content,rating) -> myDocSchema.product_reviews.reviews(content,rate),
	cs.Review(rating) -> myDocSchema.product_reviews.reviews(rate2),
	cs.commentReview.comments -> myDocSchema.product_reviews.reviews.comments(),
	cs.Comment(comment) -> myDocSchema.product_reviews.reviews.comments(comment),
	cs.Client(lastname,firstname,age, clientnumber) -> myRelSchema.Customer(lastName, firstName,age, clientnumber)
}

databases {
		mariadb myMariaDB {
		host : "192.168.1.9"
		port : 3396
		dbname : "db1"
		login : "user1"
		password : "pass1"
	}
	
	sqlite mysqlite {
		host: "sqlite.unamur.be"
		port: 8090
	}
	
	mongodb mymongo {
		host : "localhost"
		port:27000
	}
}
