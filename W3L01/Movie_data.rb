class MovieData
  attr_reader :dataList, :users, :numbers, :movies, :movieFake, :popList
  
  #*********************Movie Class**************************
  class Movie
    attr_reader :movie_id, :reviews, :popularity, :mean_rating, :users_seen
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
  end 

  #**********************User Class************************
  class User
    attr_reader :user_id, :movies_seen, :movies_ratings #movies_ratings is hash, movies_seen is list of movies    
    def initialize (u)
      @user_id = u
      @movies_ratings = Hash.new 
      @movies_seen = Array.new
    end    
    def to_s
      puts "user: #{user_id}, movies_seen#{@movies_seen}"
    end  
    def addMovie (m, r)
      @movies_ratings[m] = r
      @movies_seen.push(m)
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
  
  def popularityList
    @popList = Hash.new
    count = 0
    #gets popularity for each movie and adds to list 
    for x in @movies.each do 
      @popList[x.movie_id] = x.popularity
      count = count + 1
    end
    #sort hash by how many times a movie has been seen (popularity) 
    @popList = Hash[@popList.sort_by{|k, v| -v}]
    @popList.keys
  end 
  
  def similarity (x, y)
    x = x.movies_seen
    y = y.movies_seen
    #finds which movies both users have seen 
    count = 0
    x.each do |xReview|
      y.each do |yReview|
        if xReview == yReview
          count = count + 1.0
        end 
      end 
    end   
    #determine similarity based on how many of the same movies they've both watched
    #gets the percentage of how many movies for each person and then averages it between the tow percentages
    prct = 0
    if count != 0 
      prct = ((((count/ x.length) + (count/ y.length) )/ 2.0)*100).round(2)
    end 
    return prct
  end 
  
  def mostSimilar (x, group)
    #initialize variables
    bestPrct = 0.0
    bestUser = 0
    prct = 0.0
    comparedYet = Array.new 
    for y in group.each do 
      y = @users[@numbers.index(y)]
      if ((x.user_id != y.user_id) & !(comparedYet.include?(y.user_id)))
        comparedYet.push(y.user_id)
        prct = similarity(x, y)
        #if has bigger prct change most similar to the current user
        if prct > bestPrct
          bestPrct = prct
          bestUser = y
        end 
      end 
    end 
    bestUser
  end 
end 

#******************************START OF PA2 ********************************************************
class DataMovie2 < MovieData
  
  #constructor that takes a path to the folder containing the movie data
  def initialize (filePath)
    loadData(filePath+"u.data")
  end 
  
  #constructor can be used to specify that a particular base/training set pair should be read
  def initialize (filePath, spec)
    loadData(filePath+"u1.base")
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

  #returns a floating point number between 0.0 and 5.0 as an estimate 
  #of what user u would rate movie m
  def predict (u, m)
    #get list of all people who have seen movie m 
    u = @users[@numbers.index(u)]
    group = @movies[@movieFake.index(m)].users_seen
    person = mostSimilar(u, group)
    return rating(person.user_id, m)
  end 

  #returns the array of movie that user u has watched
  def movies (u)
    return @users[@numbers.index(u)].movies_seen 
  end 

  #returns the array of users that have seen movie m 
  def viewers (m) 
    reuturn @movies[@movieFake.index(m)].users_seen
  end 

  #runs the z.predict method on the first k ratings in the test set and returns
  #a MovieTest object containing the results 
  def runTest (k) 
    test = MovieTest.new
    count = 0
    k.times do 
      #puts "before prediction  #{Time.now}"
      test.results[count] = [@dataList[count].user_id, @dataList[count].movie_id, rating(@dataList[count].user_id, @dataList[count].movie_id)[0], predict(@dataList[count].user_id, @dataList[count].movie_id)[0]]
      count = count + 1
      #puts "after prediction  #{Time.now}"
    end
    test.to_a
  end
end 

#stores a list of all of all of the results, where each result is a tuple
#containing the user, movie, rating, and the predicted rating
class MovieTest
  attr_reader :results
  
  def initialize
    @results = Array.new
  end 
  
  #returns the average prediction error (which should be close to zero)
  def mean 
    errors = 0.0
    for x in @results.each do 
      errors = errors + (x[3] - x[2])
    end 
    puts "mean: #{-errors/@results.length}"
  end 

  #returns the standard deviation of the error 
  def stddev 
    count = 0.0 
    for x in @results.each do 
      count = count + ((x[3] - x[2])**2)
    end 
    std = Math.sqrt(count/@results.length)
    puts "standard deviation #{std}"
    std 
  end 

  #returns the root mean square error of the prediction
  def rms 
    count = 0.0 
    for x in @results.each do 
      count = count + x[2]
    end 
    count = count/@results.length  
    pred = 0.0 
    for x in @results.each do 
      pred = pred + (count - x[3]) **2
    end 
    rms = Math.sqrt(pred/@results.length)
    puts "Root Mean Square: #{rms}"
    rms 
  end 

  #returns an array of the predictions in the form [u, m, r, p]
  def to_a 
    #keeping track of errors 
    zero = 0.0
    one = 0.0
    two = 0.0
    three = 0.0
    four = 0.0
    #display results 
    puts"User\tMovie\tRating\tPredic\tCrrct?\t1 off?\t2 off?\t3 off?\t4 off?"
    #puts Time.now 
    for x in @results.each do 
      print "#{x[0]}\t#{x[1]}\t#{x[2]}\t#{x[3]}\t"
      if (x[2]==x[3]) 
        puts "yes\t" 
        zero = zero + 1
      end 
        if ((x[2]-x[3])).abs == 1
          puts "\tyes"
          one = one + 1
        end 
          if ((x[2]-x[3])).abs == 2
            puts "\t\tyes"
            two = two + 1
          end 
            if ((x[2]-x[3])).abs == 3
              puts "\t\t\tyes"
              three = three + 1
            end 
              if ((x[2]-x[3])).abs == 4
                puts "\t\t\t\tyes"
                four = four + 1
              end  
    end 
    #puts Time.now 
    puts "--------------------------------------------------------------------------\nTotal Results:" 
    print "Completely correct: #{zero}, --> #{zero/@results.length*100}%\nOne off: #{one}, --> #{one/@results.length*100}%\n"
    print "Two off: #{two}, --> #{two/@results.length*100}%\nThree off: #{three}, --> #{three/@results.length*100}%\n"
    puts "Four off: #{four}, --> #{four/@results.length*100}%"
    mean 
    stddev
    rms 
  end 
end 


rachel = DataMovie2.new("/Users/rachelburkhoff/Desktop/ml-100k-1/", 1)
rachel.runTest(10)
