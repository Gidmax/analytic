def find_or_create(record,find)
  result = record.where(find).first
  unless result
    result = record.create(find)
  end
  return result
end

user1 = find_or_create( User, {email: "chinnatip@me.com"} )
user2 = find_or_create( User, {email: "palawast@gmail.com"} )
user3 = find_or_create( User, {email: "chin@kohlife.com"} )

user1.update_attributes!({
  :name => "Chinnatip taemkaeo",
  :role => "admin" ,
  :password => "dikw2017" ,
  :password_confirmation => "dikw2017"
})

user2.update_attributes!({
  :name => "Palawast jeamsaard",
  :role => "admin",
  :password => "dikw2017" ,
  :password_confirmation => "dikw2017"
})

user3.update_attributes!({
  :name => "Chinnatip taemkaeo",
  :role => "member",
  :password => "dikw2017" ,
  :password_confirmation => "dikw2017"
})

user1.save
user2.save
user3.save
