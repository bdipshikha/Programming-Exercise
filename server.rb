require 'sinatra'
require 'pry'
require 'active_record'
require 'bcrypt'
require 'json'
require 'rdiscount'

require_relative 'models/problem'
require_relative 'models/answer'
require_relative 'models/comment'
require_relative 'models/user'

enable :sessions

#Problem starts here:
get '/' do 
	redirect '/login'
end

#to see all the problems
get '/problems' do
   student = (session[:logged_in_user_type] == 'student')
   teacher = (session[:logged_in_user_type] == 'teacher')
   is_creator = session[:logged_in_user_id]
	 problems = Problem.all
   answers = Answer.limit(6)
	 erb :index, locals: {problems: problems, answers: answers, student: student, teacher: teacher, is_creator: is_creator}
end

# to render new problem form
get '/problems/new' do
	erb :new_problem
end

#to create a problem and post it in the index form
post '/problems' do
  # grab the fields from the new problem form
  # created_by = params[]
  title = params[:title]
  content = params[:content]

  # create a new problem with the values in those fields
  Problem.create({
    created_by: session[:logged_in_user_id],
    title: title, 
    content: content,
    })
  # redirect to /problems
  redirect('/problems')
end

#to see individual problem
get '/problems/:id' do
  student = (session[:logged_in_user_type] == 'student')
  teacher = (session[:logged_in_user_type] == 'teacher')
	problem = Problem.find(params[:id])
  # getting the user_id from the session for creating problem
  is_creator = session[:logged_in_user_id] == problem.created_by
  # getting the username from the session for creating the problem
  str_user_name = session[:logged_in_user_name] == User.find(problem.created_by).username
  user = User.find(problem.created_by).username
  str_user_image = session[:logged_in_user_name] == User.find(problem.created_by).userimage
  user_image = User.find(problem.created_by).userimage
  answers = Answer.where(problem_id: problem.id) # getting all the answers created under specific problem

  markdown = RDiscount.new(problem.content)
  # puts markdown.to_html

	erb :show_problem, locals: {str_user_image: str_user_image, user_image: user_image, user: user, problem: problem, answers: answers,  markdown_html: markdown.to_html, teacher:  teacher, student: student, is_creator: is_creator, str_user_name: str_user_name}
end


#to render edit problem form
get '/problems/:id/edit' do
  # Retrieve problem from database
  problem = Problem.find(params[:id])
  # render 'edit_problem form' 
  erb :edit_problem, locals: {problem: problem}
end

#to uodate problem
put '/problems/:id' do
  problem = Problem.find(params[:id])
 
 #grab the values from edit form
  title = params[:title]
  content = params[:content]

  #update the problem with the values obtained from the edit form
  problem.update ({
    title: title,
    content: content
  })
  redirect '/problems/' + params[:id] 
end

#delete problem
delete '/problems/:id' do
  # retrive the problem from database
  problem = Problem.find(params[:id])
  # delete from database
  problem.destroy
  redirect '/problems'
end

#answer starts here


#to render new answer form
get '/problem/:problem_id/answers/new' do
  erb :new_answer, locals: {'problem_id' => params[:problem_id]}
end


#to create answer under a specific problem
post '/problem/:problem_id/answer/save' do
  # grab the fields from the new answer form
  problem_id = params[:problem_id]
  title = params[:title]
  content = params[:content]

  # create a new answer with the values in those fields
  Answer.create({
    created_by: session[:logged_in_user_id],
    problem_id: problem_id,
    title: title, 
    content: content
    })
  # redirect to /
  redirect '/problems/' + params[:problem_id]
end


#to see a particular answer
get '/answer/:id' do
  is_student = (session[:user_type] == 'student')
  is_teacher = (session[:user_type] == 'teacher')
  # retrive the specific answer from database
  
  answer = Answer.find(params[:id])
  is_creator = session[:logged_in_user_id] == answer.created_by
  puts(is_creator)
  str_user_name = session[:logged_in_user_name] == User.find(answer.created_by).username
  puts(str_user_name)
  user = User.find(answer.created_by).username
  str_user_image = session[:logged_in_user_name] == User.find(answer.created_by).userimage
  user_image = User.find(answer.created_by).userimage
# for comments
  comments = Comment.where(answer_id: answer.id)
  # comments.each do |comment|
  #   is_comment_creator = session[:logged_in_user_id] == comment.created_by
  #   puts("line 149")
    # puts(is_comment_creator)
    # str_commentor_name = session[:logged_in_user_name] == User.find(comment.created_by).username
    # puts("line 152")
    # puts(str_commentor_name)
#    commentor_name = User.find(comment.created_by).username
#    puts("line 155")
#    puts(commentor_name)

  erb :show_answer, locals: {str_user_image: str_user_image, user_image: user_image, user: user, answer: answer, comments: comments, is_teacher: is_teacher, is_creator: is_creator, is_student: is_student}
end

# to edit an answer
get '/answer/:id/edit' do
  answer = Answer.find(params[:id])
  erb :edit_answer, locals: {answer: answer}
end

# to update an answer in the database
put '/answer/:id' do

  answer = Answer.find(params[:id])

  title = params[:title]
  content = params[:content]


   answer.update({
    title: title, 
    content: content
    })
redirect '/answer/' + params[:id]

end

# to delete an answer from the database
delete '/answer/:id' do
  # retrieve the particular answer from database
  answer = Answer.find(params[:id])
  answer.destroy
  redirect '/problems'
end
#Post ends here

#Comment starts here:

post '/answer/:answer_id' do
  #getting all the values from the form
  answer_id = params[:answer_id]
  comment = params[:comment]
  #creating comment with the values from the form
   Comment.create({
    created_by: session[:logged_in_user_id],
    answer_id: answer_id,
    comment: comment,
    })
redirect '/answer/' + params[:answer_id]

end


#user authentication starts here:

get '/login' do
  erb :login 
end

#create an user
post '/create-user' do
  #create a user, encrypt their password
  #make sure the password is what the user wants
  #
  if params[:password] == params[:confirm_password]
    #encrypt the password
    pass = BCrypt::Password.create(params[:password])
    User.create(username: params[:username], usertype: params[:usertype], userimage: params[:userimage], password_digest: pass)

    session[:logged_in_user_type] = params[:usertype] # 'teacher' or 'student'
   
    redirect '/problems'
  else
    erb :login
  end
end

#create session
post '/create-session' do
  user = User.find_by(username: params[:username])
  #if the user's name exists check their password
  if user
    #'unBcrypt' the stored password and see if it is equal to the entered password
    if BCrypt::Password.new(user.password_digest) == params[:password]
      session[:logged_in_user_type] = user.usertype
      session[:logged_in_user_id] = user.id
      session[:logged_in_user_name] = user.username
      # puts ('username:' + user.id.to_s + 'usertype:' + user.usertype)
      redirect '/problems' 
    else
      erb :login
    end
  end
  erb :login #locals: {err: "incorrect name", msg: ''}
end

get '/sign-up' do
  erb :sign_up
end
#to logout
get '/logout' do
  session.clear
  redirect '/login'
end










