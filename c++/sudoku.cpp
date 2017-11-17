// g++ -std=c++11 sudoku.cpp -o sudoku

#include <string>
#include <iostream>
#include <stdlib.h>
#include <time.h>
#include <vector>
#include <tuple>

#define EMPTY "* "
#define FIXOS 14
#define MAX 6
#define TAMLINHAREGIAO 2
#define TAMCOLUNAREGIAO 3

using namespace std;

string matrizResposta[MAX][MAX];
string matrizJogo[MAX][MAX];

typedef vector< tuple<int, int> > tuple_list;

tuple_list posicoesRestritas;

int entradaUsuario(){
  string entrada = "";
  int entradaInt = 0;
  getline(cin, entrada);
	try{
	    if(entrada.size() > 1){
	      throw invalid_argument("");
	    }
	  	entradaInt = stoi(entrada);
	  	return entradaInt;
	}catch(invalid_argument e){
	  return 0;
	}
  
}

void printTabela(){

    for(int i = 0; i < MAX; i++){
      cout << endl;
      if(i % 2 == 0){
        cout << "-----------------------" << endl << "| ";
      } else{
        cout << "| "; 
      }
      for(int j = 0; j < MAX; j++){
        cout << matrizJogo[i][j] << " ";
        if(j == 2){
          cout << "| ";
        } else if(j == 5){
          cout << "|";
        }
      }
    }
  
  cout << endl << "-----------------------" << endl;

  cout << endl << endl;
}

//como validar numeros

bool numeroValido(int numero){
  if(numero >= 1 and numero <= MAX){
    return true;
  }
  return false;
}

bool matrizCheia(){
  for(int i = 0; i < MAX; i++){
    for(int j = 0; j < MAX; j++){
      if(matrizJogo[i][j] == EMPTY){
        return false;
      }
    }
  }
  return true;
}

bool validaJogada(int linha, int coluna){
  
  for(int i = 0; i < posicoesRestritas.size(); i++){
    int linhaRestrita = -1;
    int colunaRestrita = -1;
    tie(linhaRestrita, colunaRestrita) = posicoesRestritas[i];
    if(linha == linhaRestrita and coluna == colunaRestrita){
      cout << endl << "=> Posicao Invalida <=" << endl;
      return false;
    }
  }
  return true;
}

void jogadaUsuario(){

  int linha;
  int coluna;
  int numero;

  cout << "Linha: ";
  linha = entradaUsuario();
  
  if(!numeroValido(linha)){
    cout << endl << "=> Entrada Invalida <=" << endl;
    return;
  }
  
  linha = linha - 1;

  cout << "Coluna: ";
  coluna = entradaUsuario();
  
  if(!numeroValido(coluna)){
    cout << endl << "=> Entrada Invalida <=" << endl;
    return;
  }
  
  coluna = coluna - 1;

  cout << "Numero: ";
  numero = entradaUsuario();

  if(!numeroValido(numero)){
    cout << endl << "=> Entrada Invalida <=" << endl;
    return;
  }
  
  if(validaJogada(linha, coluna)){
    matrizJogo[linha][coluna] = to_string(numero) + " ";
  }
}

string randomNum(){

  string x = to_string(rand() % MAX + 1);

  return x;
}

void jogadaAutomatica(){
  
  int linha = stoi(randomNum()) - 1;
  int coluna = stoi(randomNum()) - 1;
  
  if(matrizCheia()){
    cout << endl << "=> Não há mais dicas <=" << endl;
    return;
  }
  
  while(matrizJogo[linha][coluna] != EMPTY){
    linha = stoi(randomNum()) - 1;
    coluna = stoi(randomNum()) - 1;
  }
  
  matrizJogo[linha][coluna] = matrizResposta[linha][coluna] + " ";
}

// como verificaRegiao

bool verificaRegiao(int linha, int coluna, string numeroVerifica){
  linha = linha - (linha%TAMLINHAREGIAO);
  coluna = coluna - (coluna%TAMCOLUNAREGIAO);
  for(int i = 0; i < TAMLINHAREGIAO; i++){
    for(int j = 0; j < TAMCOLUNAREGIAO; j++){
        if(matrizResposta[i+linha][j+coluna] == numeroVerifica){
          return true;
        }
    }
  }
}

// como verificaColuna

bool verificaColuna (int coluna, string numeroVerificaColuna){
  for(int j = 0; j < MAX; j ++){
    if(matrizResposta[j][coluna] == numeroVerificaColuna){
      return true;
    }
  }
}

//como  verificaLinha
bool verificaLinha(int linha, string numeroVerificaLinha){
  for(int i = 0; i < MAX; i ++){
    if(matrizResposta[linha][i] == numeroVerificaLinha){
      return true;
    }
  }
}

bool verificaSudoku(int linha, int coluna, string numero){
    return (verificaColuna(coluna,numero) or verificaLinha(linha,numero) or verificaRegiao(linha, coluna, numero));
}

void zeraMatriz(string m[MAX][MAX]){
    for(int i = 0; i < MAX; i++){
        for(int j = 0; j < MAX; j++){
            m[i][j] = EMPTY;
        }
    }
}

void cloneTabela(){
  zeraMatriz(matrizJogo);
  for(int i = 0; i < FIXOS; i++){
    int linha = std::stoi(randomNum()) - 1;
    int coluna = std::stoi(randomNum()) - 1;
    if(matrizJogo[linha][coluna] == EMPTY){
      matrizJogo[linha][coluna] = matrizResposta[linha][coluna] + ".";
      posicoesRestritas.push_back( tuple<int,int>(linha,coluna));
    } else{
      i--;
    }
  }
}

void preencherTabela(){

  for(int i = 0; i < MAX; i++){
    for(int j = 0; j < MAX; j++){
      string numeroTabela = randomNum();
      int count = 0;
      while(verificaSudoku(i,j,numeroTabela)){
        count++;
        numeroTabela = randomNum();
        if(count > 720){
          zeraMatriz(matrizResposta);
          i = 0;
          j = 0;
          break;
        }
      }
      matrizResposta[i][j] = numeroTabela;
    }
  }
  
}

bool jogoCompleto(){
  
  bool venceu = true;
  int numJogo = 0;
  for(int i = 0; i < MAX; i++){
      for(int j = 0; j < MAX; j++){
          try{
            numJogo = stoi(matrizJogo[i][j]);
          } catch(invalid_argument e){
            return false;
          }
          int numResposta = stoi(matrizResposta[i][j]);
          if(numJogo != numResposta){
            venceu = false;
          }
      }
  }
  return venceu;
}

void gameLoop(){
  bool game = true;
  int opcao = 0;

  printTabela();

  while(game){
    
    if(jogoCompleto()){
      cout << "---------------- Voce venceu ----------------" << endl;
      break;
    }

    cout << "1 - Realizar Jogada" << endl;
	  cout << "2 - Dica" << endl;
	  cout << "3 - Terminar jogo" << endl;
	  
    cout << endl << "Opcao: ";
	  opcao = entradaUsuario();

    switch(opcao){
      case 1:
        jogadaUsuario();
        printTabela();
        break;
      case 2:
        jogadaAutomatica();
        printTabela();
        break;
      case 3:
        cout << endl << "---------------- Fim de Jogo ----------------" << endl;
        game = false;
        break;
      default:
        cout << endl << "=> Entrada Invalida <=" << endl << endl;
        break;
    }
  }
}

void printSobre(){
  cout << endl << "Esse programa é parte do projeto da disciplina Paradigmas de Linguagem de Programação no período 2017.2, do curso de Ciência da Computação na UFCG, feito em grupo formado pelos seguintes alunos: " << endl << endl;
  cout << "Adauto Barros - 114211302" <<endl;
  cout << "João Lucas - 114211023" <<endl;
  cout << "Lucas Barros - 115111579"<<endl;
  cout << "Maiana Brito - 115110753" <<endl;
  cout << "Williamberg Ferreira - 117210904" <<endl <<endl;
  
  
}

void printIntro(){
  cout << endl << "Sudoku, é um jogo baseado na colocação lógica de números. O objetivo do jogo é a colocação de números de 1 a 6 em cada uma das células vazias numa grade de 6x6, constituída por 6 subgrades de 2x3 chamadas regiões. O quebra-cabeça contém algumas pistas iniciais, que são números inseridos em algumas células, de maneira a permitir uma indução ou dedução dos números em células que estejam vazias. Resolver o problema requer apenas raciocínio lógico e algum tempo." << endl<<endl;
}

void sudoku(){
  
  string input = "";
	int opcao = 0;

	cout << "1 - Iniciar" << endl;
	cout << "2 - O que é Sudoku?" << endl;
	cout << "3 - Sobre" << endl;
	cout << "4 - Sair" << endl;


	cout << endl << "Opcao: ";
	opcao = entradaUsuario();

	switch(opcao) {
		case 1:
		  preencherTabela();
		  cloneTabela();
		  gameLoop();
		  break;
		case 2:
		  printIntro();
		  sudoku();
		  break;
		case 3:
		  printSobre();
		  sudoku();
		  break;
		case 4:
		  cout << endl << "---------------- Fim de Jogo ----------------" << endl;
		  break;
		default:
		  cout << endl << "=> Entrada Invalida <=" << endl << endl;
		  sudoku();
		  break;
	}
}

int main() {

  srand(time(NULL));
  cout << "---------------- MiniSudoku ---------------- " << endl << endl;
  sudoku();
	return 0;
}