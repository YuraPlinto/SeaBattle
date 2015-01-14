class Field
=begin
Класс Field отвечает за представление поля.
Он инкапсулирует все методы ввода/вывода для экземпляра поля.
В классе описаны все возможные состояния поля.
В класс встроено распознавание координат.
Класс ведёт учёт количества живых кораблей и хранит информацию
сдался ли пользователь - владелец поля.

Не имеет значения в однопользовательской или многопользовательской игре будет использован класс.
Класс не отвечает за игровую логику (неважно сколько и каких кораблей нужно потопить для победы,
каковы правила заполнения поля, где и как оно заполняется, каков порядок ходов в случае
многопользовательской игры).

@field - это массив состояний клеток поля.
0 - закрытая пустая клетка
1 - закрытая неповреждённая клетка корабля
2 - открытая пустая клетка поля
3 - открытая повреждённая клетка корабля

@surrender - это флаг сдачи для экземпляра поля
=end
  @letterToNumber
  attr_reader :letterToNumber

  @field

  @surrender
  attr_reader :surrender

  @shipCount#Общее количество клеток поля, занятых кораблями
  attr_reader :shipCount

  #В переменной @shipCountByDeck храниться коллекция типов кораблей
  #(в виде количества палуб)и количество кораблей для кадого типа
  @shipCountByDeck

  def initialize(type, value1, value2, value3, value4)
    @shipCountByDeck=Hash.new
    @shipCountByDeck.[]=(1, value1)#singleDeckCount
    @shipCountByDeck.[]=(2, value2)#doubleDeckedCount
    @shipCountByDeck.[]=(3, value3)#threeDeckedCount
    @shipCountByDeck.[]=(4, value4)#fourDeckedCount

    @shipCount=0
    @shipCountByDeck.each do |key,val|
      @shipCount+=key*val
    end

    @letterToNumber=Hash.new
    letter='A'
    for i in 0..9 do
      @letterToNumber.[]=(letter, i)
      letter.succ!
    end
    @field=Array.new(10)
    @field.each_index { |x|
      @field[x]=Array.new(10, 0)
    }
    @surrender=false
    #Далее расставим корабли
    case type
      when 0
        #Расстановка кораблей случайным образом
        result=false
        loop do
          result=fillFieldByRandom
          if (result==true) then
            break
          else
            #print "Failed fill the field randomly! Try again.\n"
            #gets
            #Обнулим поле после неудачного заполнения
            @field.each_index { |x|
              @field[x].each_index { |y|
                @field[x][y]=0
              }
            }
          end
        end
      when 1
        #Ручная расстановка кораблей на поле
        fillFieldByHands
      else
        #Если в инциализатор передано незаданное значение аргумента type
        print "Error! Unknown type in initialize method.\n"
    end
  end

  def shoot(value)
    coordinates=parseUserInputString(value)
    #Если введены корректные координаты - можно стрелять
    if (coordinates!=false) then
      #Далее стреляем (изменяем состояние массива клеток поля)
      #Сейчас по уже поражённым клеткам стрелять можно - их состояние просто не изменится.
      #Если это поведение требуется изменить, то можно сообщать об ошибках
      #в соответствующих ветвях данного оператора case.
      case @field[coordinates[0]][coordinates[1]]
        when 0, 2
          @field[coordinates[0]][coordinates[1]]=2
        when 1
          @field[coordinates[0]][coordinates[1]]=3
          @shipCount-=1
        when 3
          @field[coordinates[0]][coordinates[1]]=3
        else
          system('cls')
          puts 'Error! Not valid value in field.'
          gets
          exit 1
      end
    end
    #Иначе ничего не делаем
  end

  #Проверить!!!
  def setCell(coord1, coord2)
      case @field[coord1][coord2]
        when 0
          @field[coord1][coord2]=1
          return true
        when 1
          return false
        when 3
          system('cls')
          puts "Error! Field you try to fill aren't empty.\n"
          gets
          exit 1
        else
          system('cls')
          puts 'Error! Not valid value in field.'
          gets
          exit 1
      end
  end

  def parseUserInputString (value)
    result=Array.new
    str=value.to_s.strip!
    if (str=~/\b(S|s)urrender\b/) then
      @surrender=true
      return false
    else
      #Далее определим, введены координаты в допустимом формате или что-то иное
      if !(str=~/[A-J]([1-9]|10)\b/) then
        print "Not valid value of coordinates! Try again.\n"
        gets
        return false
      else
        #2-ая координата
        result[1]=@letterToNumber[str[0]]
        str=str[1,str.length]
        #1-ая координата
        result[0]=str.to_i-1#Учитываем, что номерация в массиве с 0, а для пользователя с 1
        return result
      end
    end
  end

  def checkNextCell(value1, value2, coord1, coord2)
    #аргументы value1, value2 - это координаты проверяемой клетки
    #аргументы coord1, coord2 - это координаты предыдущей клетки устанавливаемого корабля
    flag=true
    #Сначала проверим, находится ли проверяемая клетка в поле
    if (value1>=0)&&(value2>=0)&&(value1<=9)&&(value2<=9) then
      #Проверка подходит ли клетка для установки следующей клетки корабля.
      #     ****X****
      #     ***XOX***
      #     ****X****
      #Она должна находиться на "кресте" вокруг предыдущей клетки, которая передаётся
      #в метод как аргумент.
      if ((value1==coord1)&&(value2==coord2+1))||((value1==coord1)&&(value2==coord2-1))||
         ((value1==coord1+1)&&(value2==coord2))||((value1==coord1-1)&&(value2==coord2)) then
        #Проверим клетки окружения, чтобы понять в допустимое ли место мы поставили палубу корабля.
        for i in (value1-1)..(value1+1) do
          for j in (value2-1)..(value2+1) do
            #Проверим, что клетка окружения с такими координатами есть в поле
            if (i>=0)&&(j>=0)&&(i<=9)&&(j<=9) then
              #Проверим, что в недопустимой близости нет кораблей кроме предыдущей клетки
              #устанавливаемого в данный момент. (На уже открытые клетки
              #ставить корабли тоже нельзя. Если это нужно, то следует изменить условие ниже.)
              if ((@field[i][j]!=0)&&((i!=coord1)||(j!=coord2))) then
                flag=false
              end
            end
          end
        end
      else
        flag=false
      end
    else
      flag=false
    end
    return flag
  end

  def determineDirection(coordinates, oldCoordinates)
    #Функция принимает два массива координат по 2 элемента в каждом.
    #Функция возвращает числовое обозначение одного из 4-х направлений.
    direction=0 if ((coordinates[0]==oldCoordinates[0])&&(coordinates[1]==oldCoordinates[1]+1))
    direction=1 if ((coordinates[0]==oldCoordinates[0])&&(coordinates[1]==oldCoordinates[1]-1))
    direction=2 if ((coordinates[0]==oldCoordinates[0]+1)&&(coordinates[1]==oldCoordinates[1]))
    direction=3 if ((coordinates[0]==oldCoordinates[0]-1)&&(coordinates[1]==oldCoordinates[1]))
    return direction
  end

  def fillFieldByHands
    direction=0#Переменная используется чтобы определять в какую сторону повёрнут корабль.
    newDirection=0#Переменная используется для сравнения направлений.
    coordinates=Array.new
    oldCoordinates=Array.new
    deckCount=0
    #Создадим в методе локальную копию переменной, хранящей количество корабельных клеток
    cellsToFill=@shipCount
    #Создадм в методе локальную копию хэша, хранящего количество кораблей по палубам
    notPlaced=Hash.new
    @shipCountByDeck.each do |key, val|
      notPlaced.[]=(key, val)
    end
    while cellsToFill>0 do
      system('cls')
      printFieldWhileFill
      loop do
        print "Enter count of decks:\n"
        deckCount=gets
        break if (deckCount=~/\A[1-4]\Z/)
        print "Error! Not valid count of decks. Try again.\n"
        gets
        system('cls')
        printFieldWhileFill
      end
      deckCount=deckCount.to_i
      currentDeck=1
      if (notPlaced[deckCount]>0) then
        #Корабли нужного типа есть. Ставим корабль.
        while (currentDeck<=deckCount) do
          #Цикл установки первой клетки корабля
          loop do
            system('cls')
            print "Enter coordinates of cell to fill.\n"
            st=gets
            coordinates=parseUserInputString(st)
            if (coordinates!=false) then
              #Тут проверяем подходящая ли клетка выбрана,
              #тип проверки зависит от того какая по счёту палуба устанавливается
              case currentDeck
                when 1
                  result=checkCellForShooting(coordinates[0], coordinates[1])
                when 2
                  result=checkNextCell(coordinates[0], coordinates[1], oldCoordinates[0], oldCoordinates[1])
                  #Установка второй палубы корабля определяет в какую сторону он повёрнут.
                  #Выявим это направление.
                  direction=determineDirection(coordinates, oldCoordinates)
                else
                  #result=checkOtherCell(coordinates[0], coordinates[1])
                  #Определим в какую сторону смотрит последняя поставленая палуба относительно предпоследней.
                  newDirection=determineDirection(coordinates, oldCoordinates)
                  if (newDirection==direction) then
                    result=checkNextCell(coordinates[0], coordinates[1], oldCoordinates[0], oldCoordinates[1])
                  else
                    result=false
                  end
              end
              if (result!=false) then
                result=setCell(coordinates[0], coordinates[1])
              end
              #Если в какая-либо функция из вызванных выше вернула false, значит координаты неправильные
              if (result==false) then
                print "Not suitable coordinates! Try to enter coordinates again.\n"
                gets
              else
                #Если ошибок не было ни в одной из функций, значит клетка успешно заполнена
                #Из цикла выбора клетки для заполнения можно выйти
                cellsToFill-=1
                #Сохраним координаты предыдущей палубы, если она есть
                oldCoordinates = coordinates.clone
                break
              end
            end
          end
          currentDeck+=1#Переходим к следующей палубе, если она предусмотрена типом корабля
        end
        notPlaced[deckCount]-=1
      else
        #Кораблей нужного типа нет. Нужно выбрать другой.
        print "There aren't that ships. Choose other type.\n"
        gets
      end
    end
    system('cls')
    printFieldWhileFill
    print "All ships was placed correctly\n"
    gets
  end


  def fillFieldByRandom
    #Для некоторых последовательностей псевдослучайных чисел возможна ситуация,
    #когда все места на поле, подходящие для кораблей какого-либо размера уже
    #заняты, а корабли такого размера ещё надо ставить. Тогда цикл поиска
    #подходящего места будет работать бесконечно.
    #Чтобы это предотвратить, введём переменную-счётчик итераций цикла поиска, если
    #он превысит определённый порог, то функция должна вернуть ложное значение.
    #Это будет означать, что сформировать случайную расстановку на поле не удалось.
    counter=0
    #Метод не проверяет, есть ли достаточное количество свободных клеток на поле!
    #Чтобы избежать бесконечного цикла рекомендуется вызывать его только для пустого поля (заполненного 0).
    cellCoord1=1
    cellCoord2=1

    @shipCountByDeck.each do |key, val|
      #Найдём место для корабля случайным образом и проверим, подходит ли оно
      for i in 1..val do
        breakFlag=true
        direction=0
        counter=0#Обнулим счётчик перед циклом поиска
        loop do
          #Флаг breakFlag определяет надо ли продолжать поиск подходящих координат
          #в цикле или подходящие координаты уже найдены
          breakFlag=true
          cellCoord1=1+rand(9)
          cellCoord2=1+rand(9)
          #Выберем ориентацию случайным образом: горизонтальную или вертикальную
          direction=rand(2)
          case direction
            when 0
              #Размещаем корабль вправо от точки
              for k in 0..(key-1) do
                breakFlag=false if (checkCellForShooting(cellCoord1, cellCoord2+k)==false)
              end
            when 1
              #Размещаем корабль вниз от точки
              for k in 0..(key-1) do
                breakFlag=false if checkCellForShooting(cellCoord1-k, cellCoord2)==false
              end
            else
              system('cls')
              puts 'Error! Wrong direction to accommodate the ship.'
              gets
              exit 1
          end
          counter+=1#Ещё 1 итерация!
          return false if counter>300#Поле забито. Расставить всё не удалось!
          break if breakFlag==true
        end
        #Разместим на поле корабли
        case direction
          when 0
            #Размещаем корабль вправо от точки
            for k in 0..(key-1) do
              @field[cellCoord1][cellCoord2+k]=1
            end
          when 1
            #Размещаем корабль вниз от точки
            for k in 0..(key-1) do
              @field[cellCoord1-k][cellCoord2]=1
            end
          else
            system('cls')
            puts 'Error! Wrong direction to accommodate the ship.'
            gets
            exit 1
        end
      end
    end
    return true
  end

  def checkCellForShooting(value1, value2)
    flag=true
    #Сначала проверим, находится ли проверяемая клетка в поле
    if (value1>=0)&&(value2>=0)&&(value1<=9)&&(value2<=9) then
      for i in (value1-1)..(value1+1) do
        for j in (value2-1)..(value2+1) do
          #Проверим, что клетка окружения с такими координатами есть в поле
          if (i>=0)&&(j>=0)&&(i<=9)&&(j<=9) then
            #Проверим, что в недопустимой близости нет кораблей. (На уже открытые клетки
            #ставить корабли тоже нельзя. Если это нужно, то следует изменить условие ниже.)
            if (@field[i][j]!=0) then
              flag=false
            end
          end
        end
      end
    else
      flag=false
    end
    return flag
  end

  def printField(space)
    print ' '*(space+1)
    @letterToNumber.each_key do |key|
      print ' '+key
    end
    print "\n"
    i=1
    @field.each { |x|
      print ' '*space+i.to_s
      print' ' if i!=10#Для двузначных чисел отступ не нужен. Тут только 10 двузначное
      x.each {|y|
          case y
            when 0
              print '* '
            when 1
              if @surrender==false then
                print '* '
              else
                print 'S '
              end
            when 2
              print 'o '
            when 3
              print 'x '
            else
              system('cls')
              puts 'Error! Not valid value in field.'
              gets
              exit 1
          end
      }
      print "\n"
      i+=1
    }
    #Отступ после поля
    print "\n"
  end

  def printFieldWhileFill
    #Функция предназначена для показа содержимого поля во время его заполнения
    #Её нельзя применять для поля со следами попаданий
    print ' '
    @letterToNumber.each_key do |key|
      print ' '+key
    end
    print "\n"
    i=1
    @field.each { |x|
      print i.to_s
      print' ' if i!=10#Для двузначных чисел отступ не нужен. Тут только 10 двузначное
      x.each {|y|
        case y
          when 0
            print '* '
          when 1
            print 'S '
          else
            system('cls')
            puts 'Error! Not valid value in field.'
            gets
            exit 1
        end
      }
      print "\n"
      i+=1
    }
    #Отступ после поля
    print "\n"
    end
end