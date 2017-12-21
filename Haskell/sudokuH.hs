import System.Random
import System.IO.Unsafe
import Data.Matrix as Matriz
import Data.Vector as Vetor
import Text.Read

type Tuple = (Int,Int)

-- gera um numero randomico de 1 a 6
randomInt :: Tuple -> Int
randomInt (inicio,limite) = unsafePerformIO(randomRIO(inicio,limite))

-- verifica se a matriz esta cheia
matrizCheia :: Matrix Int -> Bool
matrizCheia m = not(Prelude.elem 0 (Matriz.toList m))

-- verifica se o numero esta entre 1 e 6
numeroValido :: Int -> Bool
numeroValido num = (num <= 6 && num > 0)

-- verifica se a celular esta vazia, ou seja, igual a 0
celulaVazia :: Matrix Int -> Tuple -> Bool
celulaVazia m (linha,coluna) = (getElem linha coluna m == 0)

-- verifica se a posicao esta na lista de posicoes validas
isPosValida :: Tuple -> [Tuple] -> Bool
isPosValida pos pv = Prelude.elem pos pv

-- valida a entrada do usuario
getLineInt :: String -> IO Int
getLineInt str = do
  putStrLn(str)
  line <- getLine
  case readMaybe line of
    Just x -> return x
    Nothing -> putStrLn "\n=> Entrada Invalida <=" >> getLineInt str

main :: IO() 
main = do
  putStrLn("---------------- MiniSudoku ----------------\n")
  let matrizResposta = preencherTabela 36 (zero 6 6)
  let pv = []
  let (matrizJogo, posValidas) = cloneTabela matrizResposta pv
  printMenu matrizJogo matrizResposta posValidas
  
printMenu :: Matrix Int -> Matrix Int -> [Tuple] -> IO()
printMenu mj mr pv = do
  putStrLn("1 - Iniciar")
  putStrLn("2 - O que é Sudoku?")
  putStrLn("3 - Sobre")
  putStrLn("4 - Sair")
  let opcao = unsafePerformIO(getLineInt ("\nOpcao: "))
  escolherOpcaoMenu mj mr pv opcao

escolherOpcaoMenu :: Matrix Int -> Matrix Int -> [Tuple] -> Int -> IO()
escolherOpcaoMenu mj mr pv 1 = jogo mj mr pv 
escolherOpcaoMenu mj mr pv 2 = do 
                  putStrLn("Sudoku, é um jogo baseado na colocação lógica de números. O objetivo do jogo é a colocação de números de 1 a 6 em cada uma das células vazias numa grade de 6x6, constituída por 6 subgrades de 2x3 chamadas regiões. O quebra-cabeça contém algumas pistas iniciais, que são números inseridos em algumas células, de maneira a permitir uma indução ou dedução dos números em células que estejam vazias. Resolver o problema requer apenas raciocínio lógico e algum tempo.\n")
                  printMenu mj mr pv
escolherOpcaoMenu mj mr pv 3 = do 
                  putStrLn("Esse programa é parte do projeto da disciplina Paradigmas de Linguagem de Programação no período 2017.2, do curso de Ciência da Computação na UFCG, feito em grupo formado pelos seguintes alunos: \n")
                  putStrLn("Adauto Barros - 114211302")
                  putStrLn("João Lucas - 114211023")
                  putStrLn("Lucas Barros - 115111579")
                  putStrLn("Maiana Brito - 115110753")
                  putStrLn("Williamberg Ferreira - 117210904\n")
                  printMenu mj mr pv
escolherOpcaoMenu mj mr pv 4 = putStrLn("\n---------------- Fim de Jogo ----------------\n")
escolherOpcaoMenu mj mr pv opcaoInvalida = do 
                  putStrLn("\n=> Opção Inválida <=\n")
                  printMenu mj mr pv

jogo :: Matrix Int -> Matrix Int -> [Tuple] -> IO()
jogo mj mr pv
  | jogoCompleto mj mr = do 
                        putStrLn(prettyMatrix mj)
                        putStrLn ("\n---------------- Voce Venceu ----------------\n")
  | otherwise = do
                putStrLn(prettyMatrix mj)
                putStrLn("1 - Realizar Jogada")
                putStrLn("2 - Dica")
                putStrLn("3 - Terminar jogo")
                let opcao = unsafePerformIO(getLineInt ("\nOpcao: "))
                escolherOpcaoJogo mj mr pv opcao

escolherOpcaoJogo :: Matrix Int -> Matrix Int -> [Tuple] -> Int -> IO()
escolherOpcaoJogo mj mr pv 1 = realizarJogada mj mr pv
escolherOpcaoJogo mj mr pv 2 = jogadaAutomatica mj mr pv
escolherOpcaoJogo mj mr pv 3
  | jogoCompleto mj mr = putStrLn ("\n---------------- Voce Venceu ----------------\n")
  | otherwise = putStrLn("\n---------------- Fim de Jogo ----------------\n")
escolherOpcaoJogo mj mr pv opcaoInvalida = do 
                    putStrLn("\n=> Opcao Invalida <=\n")
                    jogo mj mr pv

-- insere o numero dado pelo usuario, na linha e coluna tambem dada pelo usuario
realizarJogada :: Matrix Int -> Matrix Int -> [Tuple] -> IO()
realizarJogada mj mr pv = do
                  let coluna = unsafePerformIO(getLineInt ("Coluna: "))
                  let num = unsafePerformIO(getLineInt("Numero: "))
                  let linha = unsafePerformIO(getLineInt ("Linha: "))
                  validaJogada mj mr num (linha,coluna) pv

-- verifica se os numeros na entrada estao no intervalo valido e se a posicao eh valida
validaJogada :: Matrix Int -> Matrix Int -> Int -> Tuple -> [Tuple] -> IO()
validaJogada mj mr num (linha,coluna) pv 
  | numeroValido num && numeroValido linha && numeroValido coluna && isPosValida (linha,coluna) pv = do 
    jogo (setElem num (linha,coluna) mj) mr pv
  | numeroValido num && numeroValido linha && numeroValido coluna && not(isPosValida (linha,coluna) pv) = do
    putStrLn("\n=> Posicao Restrita <=\n")
    jogo mj mr pv
  | otherwise = do 
    putStrLn("\n=> Entrada Inválida <=\n")
    jogo mj mr pv

-- insere um numero valido automaticamente no tabuleiro
jogadaAutomatica :: Matrix Int -> Matrix Int -> [Tuple] -> IO()
jogadaAutomatica mj mr pv
  | matrizCheia mj = do
                    putStrLn("\n=> Não há mais dicas <=\n")
                    jogo mj mr pv
  | celulaVazia mj (linha, coluna) = jogo (setElem (getElem (linha) (coluna) (mr)) (linha,coluna) mj) mr pv
  | otherwise = jogadaAutomatica mj mr pv
  where
    linha = randomInt(1,6)
    coluna = randomInt(1,6)

-- copia a tabela resposta zerando 22 celulas, deixando apenas 14 e cria a lista de posicoes validas
cloneTabela :: Matrix Int -> [Tuple] -> (Matrix Int, [Tuple])
cloneTabela m pv = zeraCelulas m pv 22

-- zera as celulas da matriz resposta em posicoes aleatorias e salva as posicoes zeradas
zeraCelulas :: Matrix Int -> [Tuple] -> Int -> (Matrix Int, [Tuple])
zeraCelulas m pv n
  | n == 0 = (m,pv)
  | celulaVazia m (linha,coluna) = zeraCelulas m pv n
  | otherwise = zeraCelulas (setElem 0 (linha,coluna) m) pos (n-1)
  where
    linha = randomInt(1,6)
    coluna = randomInt(1,6)
    pos = pv Prelude.++ [(linha,coluna)]

-- preenche a matriz resposta aleatoriamente
preencherTabela :: Int -> Matrix Int -> Matrix Int
preencherTabela n m
  | matrizCheia m = m
  | otherwise = preencherTabela (n-1) (setCelula m 36 (1,1))

-- preenche as celulas da matriz resposta
setCelula :: Matrix Int -> Int -> Tuple -> Matrix Int
setCelula m tentativas (linha,coluna)
  | tentativas == 0 = preencherTabela 36 (zero 6 6)
  | verificaSudoku m (linha,coluna) num = setElem num (linha,coluna) m
  | coluna < 6 = setCelula m (tentativas-1) (linha, coluna + 1)
  | coluna == 6 = setCelula m (tentativas-1) (linha+1, 1)
  where
    num = randomInt(1,6)

-- verifica se a celula aleatoria respeita as regras do sudoku
verificaSudoku :: Matrix Int -> Tuple -> Int -> Bool
verificaSudoku m (linha,coluna) num = (celulaVazia m (linha,coluna)) 
  && (verificaLinha m linha num) 
  && (verificaColuna m coluna num)
  && (verificaRegiao m (linha-1,coluna-1) num)

-- verifica se o numero nao existe na linha
verificaLinha :: Matrix Int -> Int -> Int -> Bool
verificaLinha m linha num = not(Vetor.elem num (getRow linha m))

-- verifica se o numero nao existe na coluna
verificaColuna :: Matrix Int -> Int -> Int -> Bool
verificaColuna m coluna num = not(Vetor.elem num (getCol coluna m))

-- verifica se o numero nao existe na regiao
verificaRegiao :: Matrix Int -> Tuple -> Int -> Bool
verificaRegiao m (linha,coluna) num = not(Vetor.elem num regiao)
  where
    linhaInicial = linha - (linha `rem` 2) + 1
    colunaInicial = coluna - (coluna `rem` 3) + 1
    linhaFinal = linhaInicial + 1
    colunaFinal = colunaInicial + 2
    regiao = Matriz.getMatrixAsVector(submatrix linhaInicial linhaFinal colunaInicial colunaFinal m)

-- verifica se a matriz jogo eh igual a matriz resposta
jogoCompleto :: Matrix Int -> Matrix Int -> Bool
jogoCompleto mj mr = (Matriz.toList mj) == (Matriz.toList mr)
