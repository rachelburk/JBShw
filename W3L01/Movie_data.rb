class MovieData
  attr_reader :dataList, :users, :numbers, :movies, :movieFake, :popList
  
  def getMovies
      return @movies
    end 
    
    def getFMovies
      return @movieFake
    end
    
  #*********************Movie Class**************************
  class Movie
    attr_reader :movie_id, :reviews, :popularity, :mean_rating, :users_seen, :name, :date, :kind
    def initialize (m)
      @movie_id = m
      @reviews = Array.new
      @users_seen = Array.new
      @popularity = 0 
    end 
 
    def to_s 
      puts "movie id: #{@movie_id}, reviews: #{@reviews}, users who have seen it: #{@users_seen}, popularity: #{@popularity}"
    end 
    def addUser(u, r)
      @reviews.push(r)
      @users_seen.push(u)
      getPop
    end   
    def getPop
      @popularity = @popularity + 1
    end 
    
    def addInfo(x)
      @name = x[1] #adds name of movie 
      y = x[2].split("-")
      @date = y[2] #adds year of movie
      @kind = x[3] # adds genre of movie in array of 0 and 1s signifying different genres 
    end 
  end 

  #**********************User Class************************
  class User
    attr_reader :sex, :age, :profession, :user_id, :movies_seen, :movies_ratings #movies_ratings is hash, movies_seen is list of movies    
    def initialize (u)
      @user_id = u
      @movies_ratings = Hash.new 
      @movies_seen = Array.new
    end    
    def to_s
      puts "user: #{user_id}, sex: #{@sex}, age: #{@age}, profess: #{@profession}"
    end  
    def addMovie (m, r)
      @movies_ratings[m] = r
      @movies_seen.push(m)
    end  
    
    def setInfo(s, a, p)
      @sex = s
      @age = a
      @profession = p
    end 
    
  end 
  
  #***************************Review Class*******************
  class Review
    attr_reader :user_id, :movie_id, :rating
    def initialize (u, m, r)
      @user_id = u
      @movie_id = m
      @rating = r
    end     
    def to_s 
      puts "user: #{@user_id}, movie: #{@movie_id}, rating: #{@rating}"
    end 
  end 
  
  #-----------------------------------------------------------------------------------------------------------------
  
  def loadData (filePath)
    STDOUT.flush 
    data = File.open(filePath, "r") 
    
    count = 0 #counter for number of reviews 
    @dataList = Array.new #array holding list of arrays (holding data of each review) 
   
    #DEFINING REVIEW CLASS **********
    #goes through each line of data and creates an array storing all of the information and stores it in dataList
    data.each_line do |x|
      x = x.split
      @dataList[count] = Review.new(x[0].to_i, x[1].to_i, x[2].to_i)
      count = count+1
    end 
    
    #DEFINING USER CLASS ************
    #find number of users and create array holding all of the users 
    @users = Array.new #actual list of users 
    @numbers = Array.new #number list of users <-will not use later 
    count = 0
    for x in @dataList.each do
      if !(@numbers.include?(x.user_id))
        name = User.new(x.user_id)
        @users.push(name)
        @numbers[count] = x.user_id
        count = count + 1
      end 
    end 
    #set movie and the rating to each user
    for x in @dataList.each do 
      @users[numbers.index(x.user_id)].addMovie(x.movie_id, x.rating)
    end
    
    #DEFINING MOVIE CLASS************
    #find number of movie and create array holding all movies
    @movies = Array.new 
    @movieFake = Array.new
    count = 0
    for x in @dataList.each do 
      if !(@movieFake.include?(x.movie_id))
        @movies.push(Movie.new(x.movie_id))
        @movieFake[count] = x.movie_id
        count = count + 1
      end 
    end 
    #set each movie with its users and ratings 
    for x in @dataList.each do 
      @movies[@movieFake.index(x.movie_id)].addUser(x.user_id, x.rating)
    end 
  end
 
end 

#******************************START OF PA2 ********************************************************
class DataMovie2 < MovieData
  attr_reader :movieItem, :genres
  #constructor that takes a path to the folder containing the movie data
  def initialize (filePath)
    loadData(filePath+"u.data")
    loadGenre(filePath)
    loadUsers(filePath)
    loadItem(filePath) 
  end 
  
  #constructor can be used to specify that a particular base/training set pair should be read
  #def initialize (filePath, spec)
  #  loadData(filePath+"u1.base")
  #  puts "initial load data complete!"
  #  loadGenre(filePath)
  #  loadUsers(filePath)
  #  loadItem(filePath) 
  #end 
  
  #ADDITION TO PA3*****************************
  #load genres
  def loadGenre(filePath)
    data = File.open(filePath+"u.genre", "r")
    @genres = Hash.new
    data.each_line do |x|  
      x = Hash[*x.chomp.split("\n").map{|i| i.split("|")}.flatten]
      @genres = @genres.merge(x)
    end    
    #puts @genres
  end 
  
  #load user info
  def loadUsers(filePath)
    data = File.open(filePath+"u.user", "r")
    userInfo = Array.new
    data.each_line do |x|
      x = [*x.chomp.split("\n").map{|i| i.split("|")}.flatten]
      userInfo.push(x)
    end 
    
    #set user info to each user 
    count = 0
    userInfo.each do |y|
      x= userInfo[count]
      y= @users[@numbers.index(x[0].to_i)]
      y.setInfo(x[2], x[1], x[3])
      #puts y
      count = count+1
    end
    
    #puts userInfo
  end
  
  #load movie information <=====================PROBLEM WITH THIS ONE!!!!!!!
  def loadItem(filePath)
    data = File.open(filePath+"u.item", "r")
    @movieItem = Array.new
    data.each_line do |x|
      
      x= x.chomp.split("|")#.encode("UTF-8"))
      x = [x[0], x[1], x[2], [x[5], x[6], x[7], x[8], x[9], x[10], x[11], x[12], x[13], x[14], x[15], x[16], x[17], x[18], x[19], x[20], x[21], x[22], x[23]]]
      
      @movieItem.push(x)
    end 
    
    #puts @movies
    @movieItem.each do |x|
      @movies[@movieFake.index(x[0].to_i)].addInfo(x)
    end
  end
  
  #returns the rating that user u have movie m in the training set
  #and 0 if user u did not rate movie m
  def rating (u, m)
    if @users[@numbers.index(u)].movies_ratings.has_key?(m)
      return @users[@numbers.index(u)].movies_ratings.values_at(m)
    else 
      return 0
    end  
  end

  #returns the array of movie that user u has watched
  def movies (u)
    return @users[@numbers.index(u)].movies_seen 
  end 

  #returns the array of users that have seen movie m 
  def viewers (m) 
    reuturn @movies[@movieFake.index(m)].users_seen
  end 
end 

class MovieData3 < DataMovie2
    attr_reader :spec, :finalList
    
    def initialize (filePath)
      super(filePath)
      @spec = Hash.new
    end 
     
    #method that gets user specific data they are looking for 
    def getSpec(x)
      puts "Insert the #{x}"
      STDOUT.flush
      answ = gets.chomp
      return answ
    end 
    
    #this will return an array of all movies that  satisfy the constraints 
    #in the HASH which will include the following:
    def findMovies (hash) 
      #TITLE******************
      #finding movie with title within it 
      tempU1 = Array.new
      if hash.has_key?(:title)
        @movieItem.each do |x|
          x= @movies[@movieFake.index(x[0].to_i)]
          y= hash.values_at(:title)[0]
          
          if x.name.downcase.include?(y)
            tempU1.push(x)
          end 
        end 
      end 
    
      #GENRE************
      #returns movies with specific genre 
      tempU2 = Array.new
      if tempU1.empty?
        if hash.has_key?(:g)
          @movieItem.each do |x|
            movie= @movies[@movieFake.index(x[0].to_i)]
            genreId= @genres.values_at(hash.values_at(:g)[0])[0].to_i
            #puts movie.kind[genreId]
            if movie.kind[genreId].to_i==1
              tempU2.push(movie)
            end 
          end 
        end 
      else 
        if hash.has_key?(:g)
          @movieItem.each do |x|
            movie= @movies[@movieFake.index(x[0].to_i)]
            genreId= @genres.values_at(hash.values_at(:g)[0])[0].to_i
            #puts movie.kind[genreId]
            if ((movie.kind[genreId].to_i==1) & (tempU2.include?(movie)))
              tempU2.push(movie)
            end 
          end 
        else
          tempU2= tempU1
        end 
      end 
     
      
      
      return tempU2
    end 
    
    #this will return an array of all users that satisfy the constraints 
    #in the HASH, including:
    def findUsers (hash)
      #OCCUPATION ***********
      tempMovies = Array.new
      if hash.has_key?(:occup)
        @numbers.each do |x|
          y= @users[@numbers.index(x)]
          if hash.values_at(:occup)[0]==y.profession
            tempMovies.push(y)
          end 
        end 
      end 
      
      #AGE********
      tempU1 = Array.new
      if hash.has_key?(:a)
        @numbers.each do |x|
          x= @users[@numbers.index(x)]
          y= hash.values_at(:a)
          if ((x.age.to_i>=y[0][0].to_i) & (x.age.to_i<=y[0][1].to_i) & tempMovies.include?(x))
            tempU1.push(x)
          end 
        end 
      end 
   
      #SEX*********
      tempU2 = Array.new
      if hash.has_key?(:s)
        @numbers.each do |x|
          x= @users[@numbers.index(x)]
          y= hash.values_at(:s)
          y=y[0]
          #puts "#{x.sex} ==? #{y}"
          if (x.sex.eql?(y) & (tempU1.include?(x)))
            #puts "inside?"
            tempU2.push(x)
          end 
        end 
      end 
      
      return tempU2
    end 
end 

class MovieSearchDemo
   attr_reader :test
   
   def initialize 
      @test = MovieData3.new("/Users/rachelburkhoff/Desktop/ml-100k-1/")
      
      test1("Sci-Fi", 1996)
      puts "\n"
      test2([17, 21], "F", 5, "student")
      puts "\n"
      test2([17, 21], "M", 5, "student")
      
      #finds users with certain title test
      #group = @test.findMovies({:title=> "Love"})
      #puts group 
   end 
   
   #return an array of all of the movies in that genre released in that year
   def test1(genre, year)
      group = test.findMovies({:g=> genre, :y => year})
      
      #finds all movies in that specific genre of the specified year
      movies = Array.new
      group.each do |x|
        if x.date.to_i==year
          movies.push(x)
        end
      end
    
    #prints out results 
    puts"All #{genre} movies released in #{year}"
    count = 0
    (movies.length).times do  
          puts "#{count + 1}. ##{movies[count].movie_id}, #{movies[count].name}"
          count = count+1
        end 
   end 
   
   #Return an array of the top n most viewed movies by viewer with the specified sex and age
   def test2(age, sex, n, occ)
      group = test.findUsers({:occup => occ, :a=> age, :s=> sex, :n=> n})
      
      #figure out how many times a movie was seen to find the most popular and sort in descending order most popular movies (how many times seen) 
      movies = Hash.new
      group.each do |x|
        list = x.movies_seen
        list.each do |y|
          if movies.has_key?(y)
            count = movies.values_at(y)[0] + 1
            movie2=Hash.new
            movie2 [y]=movies.values_at(y)[0] + 1
            movies = movies.merge(movie2)
          else
            movies [y] = 1
          end 
        end
      end
      movies = movies.sort_by{|k, v| -v}
      
      #print out results in a nice way 
      listMovies = @test.getMovies
      list2Movies = @test.getFMovies
      if n>0
        puts "Top #{n} movies seen by #{sex}, #{age} year olds:"
        count = 0
        n.times do  
          puts "#{count + 1}. ##{movies[count] [0]}, #{listMovies[list2Movies.index(movies[count][0].to_i)].name}"
          count = count+1
        end 
      else 
        puts "Top movies seen by #{sex}, #{age} year olds:"
        count = 0
        ((movies.length)/2).times do  
          puts "#{count + 1}. ##{movies[count] [0]}, #{listMovies[list2Movies.index(movies[count][0].to_i)].name}"
          count = count+1
        end 
      end 
   end
end 

MovieSearchDemo.new
