
/* --------------------------------------- Util --------------------------------------- */
matrizVazia([[11,111 ,1111 ,11111 ,111111 ,1111111], 
		[22, 222, 2222, 22222, 222222,2222222], 
		[33, 333,3333 ,33333 ,333333 ,3333333],
		[44, 444, 4444, 44444, 444444,4444444],
		[55, 555, 5555, 55555, 555555,5555555],
                [66,666 ,6666 ,66666 ,666666 ,6666666]]).
                
                
				
				
index(Matrix, Row, Col, Value):-
  nth1(Row, Matrix, MatrixRow),
  nth1(Col, MatrixRow, Value).

copiaMatriz(6,7,MatrizJ,MatrizV,MatrizJogador):-
	MatrizJogador = MatrizV.
	
copiaMatriz(R,7,MatrizJ,MatrizV,MatrizJogador):-
	NewR is (R + 1),
	copiaMatriz(NewR,1,MatrizJ,MatrizV,MatrizJogador).

copiaMatriz(R,C,MatrizJ,MatrizV,MatrizJogador):-
	index(MatrizJ,R,C,V),
	replaceElementM(R,C,MatrizJ,V,MatrizJogador_),
	NewC is (C + 1),
	copiaMatriz(R,NewC,MatrizJ,MatrizJogador_,MatrizJogador).

regraDeInserir(R,C,Mat,Upd,30):-
	matrizVazia(NovaMatriz),
	regraDeInserir(1,1,NovaMatriz,Upd,0).
	
regraDeInserir(6,7,Mat,Upd,Tentativas):- 
    Upd = Mat.
    
regraDeInserir(R,7, Mat, Upd,Tentativas):-
    NewR is (R + 1),
    regraDeInserir(NewR,1,Mat,Upd,Tentativas).
   
regraDeInserir(R, C, Mat, Upd,Tentativas):- 
    geraNumero(Rand), 
    replaceElementM(R,C,Mat,Rand, Upd_),
    col(C,Upd_,Col),
    row(R,Upd_,Row),
    NewC is (C + 1),
    (unique(Col),unique(Row) -> regraDeInserir(R,NewC, Upd_, Upd,0);

					NewTentativas is (Tentativas + 1),regraDeInserir(R,C, Upd_, Upd,NewTentativas)).
		
zeraCelulas(MatrizJogadorCopiada,15,MatrizJogador):-
	MatrizJogador = MatrizJogadorCopiada.
	
zeraCelulas(MatrizJogadorCopiada,NumCelulasZeradas,MatrizJogador):-
	geraNumero(Row),
	geraNumero(Col),
	index(MatrizJogadorCopiada_,Row,Col,Valor),
	(Valor == 0 -> zeraCelulas(MatrizJogadorCopiada_,NumCelulasZeradas,MatrizJogador);
								replaceElementM(Row,Col,MatrizJogadorCopiada,0,MatrizJogadorCopiada_),NewNumCelulas is (NumCelulasZeradas + 1)
								,zeraCelulas(MatrizJogadorCopiada_,NewNumCelulas,MatrizJogador)).
	

replaceElementM(R, C, Mat, Val, Upd) :-
    nth1(R, Mat, OldRow, RestRows),   %get the row and the rest
    nth1(C, OldRow, _Val, NewRow),    %we dont ca
    nth1(C, NewRowUpd,Val,NewRow),	%insert Val into C, where _val was
    nth1(R, Upd, NewRowUpd, RestRows).

imprimeMenuJogada:-
	writeln("| 1. - Realizar Jogada"),
	writeln("| 2. - Dica"),
	writeln("| 3. - Finalizar Jogo ").

/*matriz resposta matriz 
cao*/
executaJogo(1,MR,MV,MJ):-
	writeln("Escreva a linha que deseja mudar (entre 1 e 6): "),
	read(Row),nl,
	writeln("Escreva a coluna que deseja mudar (entre 1 e 6): "),
	read(Col),nl,
	writeln("Escreva o numero que deseja botar no Sudoku"),
	read(Num),nl,
	index(MV,Row,Col,ValorValida),
	(ValorValida \= 0 -> writeln("voce nao pode jogar nessa posicao."),executaJogo(1,MR,MV,MJ);
	((Row < 1;Col < 1; Num < 1;Row > 6;Col > 6;Num > 6) -> write("Voce digitou um numero invalido"),nl, executaJogo(1,MR,MV,MJ)
						;	replaceElementM(Row,Col,MJ,Num,MJModificado)),nl,
	(MJ == MJModificado -> write("VOCE GANHOU, PARABENS")
						;	mainJogo(MR,MV,MJModificado))).

encontra0(6,7,MV,MJ,MR):-
	MJ = MV.
	
encontra0(R,7,MV,MJ,MR):-
	NewR is (R + 1),
	encontra0(NewR,1,MV,MJ,MR).
	
encontra0(R,C,MV,MJ,MR):-
		index(MV,R,C,ValorV),
		index(MJ,R,C,ValorJ),
		index(MR,R,C,ValorR),
		((ValorV == 0, ValorJ == 0) -> replaceElementM(R,C,MJ,ValorR,MatrizJ),mainJogo(MR,MV,MatrizJ); NewC is (C + 1),encontra0(R,NewC,MV,MJ,MR)).

executaJogo(2,MR,MV,MJ):-
	encontra0(1,1,MV,MJ,MR),
	mainJogo(MR,MV,MJ).
	
executaJogo(3,MR,MV,MJ):-
		goToFinal().

imprimeMenu :- 
	writeln("| 1. - Iniciar"),
	writeln("| 2. - O que eh sudoku?"),
	writeln("| 3. - Sobre"),
	writeln("| 4. - Sair"),nl.


/*onde a matriz jogo e jogador sera criada*/
executa(1):-
	matrizVazia(MatrizJogoVazia),
	regraDeInserir(1,1,MatrizJogoVazia,MatrizResposta,0),
	matrizVazia(MatrizJogadorVazia),
	copiaMatriz(1,1,MatrizResposta,MatrizJogadorVazia,MatrizJogadorCopiada),
	zeraCelulas(MatrizJogadorCopiada,0,MatrizJogador),
	matrizVazia(MatrizValidacaoVazia),
	copiaMatriz(1,1,MatrizJogador,MatrizValidacaoVazia,MatrizValidacao),
	mainJogo(MatrizResposta,MatrizValidacao,MatrizJogador).
	
executa(2):-
    writeln("Sudoku, eh um jogo baseado na colocação logica de numeros. O objetivo do jogo eh a colocacao de numeros de 1 a 6 em cada uma das celulas vazias numa grade de 6x6, constituida por 6 subgrades de 2x3 chamadas regioes. O quebra-cabeca contem algumas pistas iniciais, que sao numeros inseridos em algumas celulas, de maneira a permitir uma inducao ou deducao dos numeros em celulas que estejam vazias. Resolver o problema requer apenas raciocinio logico e algum tempo."),nl,main2().
executa(3) :-
    writeln("Esse programa faz parte do projeto da disciplina Paradigmas de Linguagem de Programacao no período 2017.2, do curso de Ciencia da Computacao na UFCG, feito em grupo formado pelos seguintes alunos:"),nl,
                  writeln("Adauto Barros - 114211302"),nl,
                  writeln("Joao Lucas - 114211023"),nl,
                  writeln("Lucas Barros - 115111579"),nl,
                  writeln("Maiana Brito - 115110753"),nl,
                  writeln("Williamberg Ferreira - 117210904"),nl,main2().
executa(4) :-
    halt(0).

/*mostralinha*/
mostraLinha([]).
mostraLinha([H|T]) :- 
        write(H), write('   '), mostraLinha(T).

		

/*como mostrar a matriz*/
mostraMatriz([]).
mostraMatriz([H|T]) :- 
	writeln("----------------------"),
	mostraLinha(H), writeln(''), 	
	mostraMatriz(T).


reg(Row,Col,M,Reg):-
	InitialRow is (Row - (Row mod 2)),
	InitialCol is (Col - (Col mod 3)),
	FinalRow is   (InitialRow + 1),
	FinalCow is (InitialCol + 2).
	


/*retorna a coluna toda*/
col(N, Matrix, Col) :-
    maplist(nth1(N), Matrix, Col).
    
/*retorna a linha toda*/
row(N,Matrix,Row) :-
        nth1(N,Matrix,Row).

/*ver se o elemento da lista é unico*/
unique([]).
unique([_,[]]).
unique([H|T]):-not(member(H,T)),unique(T).
    
/*gerar numero aleatorio*/
geraNumero(Num):-
	random_between(1, 6, X),
	Num is X.

fimDaExecucao():-halt(0).

goToFinal():-
	writeln("Fim do Jogo!!"),
	writeln("Digite 1. para sair"),
	writeln("Digite 2. para comecar um novo jogo"),
	read(L),
	((L == 1)-> fimDaExecucao();(L == 2) -> executa(1);writeln("Voce digitou uma opcao invalida, digite novamente"),goToFinal()).

/*recebe matriz resposta e matriz jogador*/
mainJogo(MR,MV,MJ):-
	((MR == MJ) -> writeln("Você ganhou!!!"),goToFinal();
    mostraMatriz(MJ),nl,
	imprimeMenuJogada,
	read(O),nl,
	executaJogo(O,MR,MV,MJ)).

/*menu para tirar o print do minisudoku*/	
main2:-
    imprimeMenu,
	read(L),nl,
	((L < 1; L > 4) -> writeln("Voce digitou um numero invalido"),main2;executa(L)).
    
:- initialization main.

main:-
     write("---------------- MiniSudoku ----------------"),nl,
     imprimeMenu,
     read(L),nl,
	 ((L < 1; L > 4) ->writeln("Voce digitou um numero invalido"),main2;executa(L)).
    
