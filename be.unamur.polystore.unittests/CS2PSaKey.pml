conceptual schema CS2PSaKey {
	
	entity type Order {
		id : string,
		orderdate : date,
		totalprice : float
		identifier {
			id
		}
	}
	
	entity type Customer {
		id : string,
		firstname : string,
		lastname : string,
		gender : string,
		birthday : date,
		creationDate : date,
		locationip : string,
		browser : string
		identifier{
			id
		}
	}
	
	relationship type buys {
		order[1]: Order,
		client[0-N]: Customer
	}	
}

physical schemas {
	key value schema kv : redisPerfTest {
		kvpairs ordersPairs {
			key : "ORDER:"[orderid],
			value : hash {
				dateOrder,
				amount,
				custid
			}
			references {
				clientRefKV : custid-> customerKV.customerid
			}
		}
		
		kvpairs customerKV {
			key : "CUSTOMER:"[customerid],
			value : hash {
				firstname,
				lastname,
				locationip,
				birthday,
				gender,
				creationdate,
				browser
			}
		}
	}
}

mapping rules {
		CS2PSaKey.Order(id,totalprice, orderdate) -> kv.ordersPairs(orderid,amount,dateOrder),
		CS2PSaKey.Customer(id,firstname, lastname, locationip, birthday, gender, creationDate, browser) -> kv.customerKV(customerid, firstname,lastname, locationip, birthday, gender, creationdate, browser),
		CS2PSaKey.buys.order -> kv.ordersPairs.clientRefKV
}

databases {
	redis redisPerfTest {
		host : "redisPerfTest"
		port : 6379
	}
}