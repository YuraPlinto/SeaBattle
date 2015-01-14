begin
  require_relative 'field.rb'

  #A=Field.new(0, 4, 3, 2, 1)
  A=Field.new(1, 4, 3, 2, 1)
  st=' '

  loop do
    system('cls')
    A.printField(0)
    if (A.surrender==true) then
      puts 'What a shame...'
      break
    end
    if (A.shipCount==0) then
      #≈сли на поле не осталось ни одной не подбитой корабельной клетки - игра окончена, мы победили!
      puts 'You win!'
      break
    end
    
    puts "It's time to shoot! Enter coordinates:"
    st=gets#ѕолучаем строку с координатами от пользовател€
    A.shoot(st)#ѕроверка, что в строке действительно координаты и их ввод

  end

  gets
rescue => err
  puts err
end