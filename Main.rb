begin
  require 'C:\SeaBattle\field.rb'

  Player1=Field.new(0, 4, 3, 2, 1)
  Player2=Field.new(1, 4, 3, 2, 1)
  st=' '
  #Переменная, определяющая чей ход
  move=rand(1)
  #стартовое значение (кто ходит первым) определяется случайно

  loop do
    if (move==1) then

      move=0
    else

      move=1
    end
  end

  gets
rescue => err
  puts err
end

=begin
system('cls')
    A.printField
    if (A.surrender==true) then
      puts 'What a shame...'
      break
    end
    if (A.shipCount==0) then
      #Если на поле не осталось ни одной не подбитой корабельной клетки - игра окончена, мы победили!
      puts 'You win!'
      break
    end

    puts "It's time to shoot! Enter coordinates:"
    st=gets#Получаем строку с координатами от пользователя
    A.shoot(st)#Проверка, что в строке действительно координаты и их ввод
=end