require 'pg'
require 'faker'
TITLES = ["Roasted Brussels Sprouts",
  "Fresh Brussels Sprouts Soup",
  "Brussels Sprouts with Toasted Breadcrumbs, Parmesan, and Lemon",
  "Cheesy Maple Roasted Brussels Sprouts and Broccoli with Dried Cherries",
  "Hot Cheesy Roasted Brussels Sprout Dip",
  "Pomegranate Roasted Brussels Sprouts with Red Grapes and Farro",
  "Roasted Brussels Sprout and Red Potato Salad",
  "Smoky Buttered Brussels Sprouts",
  "Sweet and Spicy Roasted Brussels Sprouts",
  "Smoky Buttered Brussels Sprouts",
  "Brussels Sprouts and Egg Salad with Hazelnuts"]
COMMENTS = []
20.times do
  COMMENTS << Faker::Lorem.sentence
end
#WRITE CODE TO SEED YOUR DATABASE AND TABLES HERE
def db_connection
  begin
    connection = PG.connect(dbname: "brussels_sprouts_recipes")
    yield(connection)
  ensure
    connection.close
  end
end
db_connection do |conn|
  conn.exec("DROP TABLE IF EXISTS recipes CASCADE")
  conn.exec("CREATE TABLE recipes(
  id SERIAL PRIMARY KEY,
  name VARCHAR(255)
  );")
  conn.exec("DROP TABLE IF EXISTS comments CASCADE")
  conn.exec("CREATE TABLE comments(
  id SERIAL PRIMARY KEY,
  comment VARCHAR(255),
  recipe_id INT REFERENCES recipes(id)
  );")


  TITLES.each do |recipe|
    conn.exec_params("INSERT INTO recipes(name) VALUES($1)", [recipe])
  end

  COMMENTS.each do |comment|
    random = rand(TITLES.count) + 1
    conn.exec_params("INSERT INTO comments(comment, recipe_id) VALUES ($1, $2)", [comment, random])
  end

  puts "Recipe Table:"
  recipes_output = conn.exec("SELECT * FROM recipes")
  recipes_output.each do |line|
    puts "#{line["id"]}. #{line["name"]}"
  end

  puts
  puts "Comments Table:"
  comments_output = conn.exec("SELECT * FROM comments")
  comments_output.each do |line|
    puts "#{line["id"]}. #{line["comment"]} #{line["recipe_id"]}"
  end

  puts
  puts "How many recipes are there in total?"
  recipe_count = conn.exec("SELECT count(*) FROM recipes")
  recipe_count.each do |info|
    puts "There are #{info["count"]} recipes."
  end

  puts
  puts "How many comments are there in total?"
  comment_count = conn.exec("SELECT count(*) FROM recipes")
  comment_count.each do |info|
    puts "There are #{info["count"]} comments."
  end

  puts
  puts "How many comments does each recipe have?"
  comment_sub = conn.exec("SELECT recipes.name AS name, count(*) AS count FROM recipes JOIN comments ON recipes.id = comments.recipe_id GROUP BY recipes.id")
  comment_sub.each do |sub|
    puts "#{sub["name"]} has #{sub["count"].to_i} comments"
  end

  puts
  puts "What is the name of the recipe associated with a specific comment?"
  comment_recipe = conn.exec("SELECT recipes.name, comments.comment FROM comments LEFT JOIN recipes ON recipes.id = comments.recipe_id")
  comment_recipe.each do |recipe|
    puts "Recipe Name: #{recipe["name"]}, Comment: #{recipe["comment"]}"
  end

  puts
  puts "Add a new recipe called Brussels Sprouts with Goat Cheese and add two comments to it."
  conn.exec_params("INSERT INTO recipes(name) VALUES ($1)", ["Brussels Sprouts with Goat Cheese"])


  ADDITIONAL_COMMENTS = []
  2.times do
    ADDITIONAL_COMMENTS << Faker::Lorem.sentence
  end

  recipe_id_of_new_comment = conn.exec("SELECT recipes.id FROM recipes WHERE recipes.name = 'Brussels Sprouts with Goat Cheese'")
  recipe_id_of_new_comment = recipe_id_of_new_comment.to_a[0]["id"]
  conn.exec_params("INSERT INTO comments(comment, recipe_id) VALUES ($1, $2)", [ADDITIONAL_COMMENTS[0], recipe_id_of_new_comment])
  conn.exec_params("INSERT INTO comments(comment, recipe_id) VALUES ($1, $2)", [ADDITIONAL_COMMENTS[1], recipe_id_of_new_comment])

  puts
  puts "Modified Comments Table:"
  comments_output = conn.exec("SELECT * FROM comments")
  comments_output.each do |line|
    puts "#{line["id"]}. #{line["comment"]} #{line["recipe_id"]}"
  end
end
