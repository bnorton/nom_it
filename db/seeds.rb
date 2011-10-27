# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


# User.register(email, pass, username='')

users  = [['brian.nort@gmail.com' ,'password','nort'],
          ['shan.forb@gmail.com'  ,'password','shanfor'],
          ['sampullman@gmail.com' ,'password','samp'],
          ['parker.mark@gmail.com','password','markparker'],
          ['parker.jim@gmail.com' ,'password','jimparker'],
          ['test1@gmail.com' ,'password','test1'],['test2@gmail.com' ,'password','test2'],['test3@gmail.com' ,'password','test3'],
          ['test4@gmail.com' ,'password','test4'],['test5@gmail.com' ,'password','test5'],['test6@gmail.com' ,'password','test6'],]
          
users.each do |user|
  User.create(*user)
end