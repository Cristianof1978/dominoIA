// Agent sample_agent in project domino

/* Initial beliefs and rules */

domino(0,6).
domino(1,6).
domino(2,6).
domino(3,1).
domino(3,5).
domino(3,6).

dominosontable([]).

/* Initial goals */

//se tem doble
temDoble(V):- domino(X,X) & V = true.
temDoble(V):- not domino(X,X) & V = false.

//sem tem maior doble
temMaiorDoble(D,X):- domino(X,X) & D = domino(X,X).
temMaiorDoble(D,X):- temMaiorDoble(D,X-1).

//se tem maior peça
temMaiorPeca(D,S):- domino(A,B) & D = domino(A,B).
temMaiorPeca(D,S):- S = A + B & temMaiorPeca(D,S-1).

//varrendo peças na mesa - numero do lado direto
consultaMesaLadoDireito(LIST,RETORNO):- LIST = [domino(A,B)] & RETORNO = B.
consultaMesaLadoDireito([H|T],RETORNO):- consultaMesaLadoDireito(T,RETORNO).

//varrendo peças na mesa - numero do lado esquerdo
consultaMesaLadoEsquerdo(LIST,RETORNO):- LIST = [domino(A,B)|T] & RETORNO = A.

//verificando maior peça à ser jogada
verificaMaiorPeca(dominoEsquerda(A,B),dominoDireita(C,D),RETORNO,LADO):- (((A + B) > (C + D)) & RETORNO = domino(A,B) & LADO = l) |
																		 (RETORNO = domino(C,D) & LADO = r).

!start.

/* Plans */

////mesa vazia = jogando maior doble
//+!start
//	: not dominosontable(_) & temDoble(V)
//	<-
//		.print("ENTROU");
//		?temMaiorDoble(domino(A,B),6);
//		//put(domino(A,B),r);
//		.print("MESA VAZIA - jogando maior doble -> ", domino(A,B));
//		//-domino(A,B);
//	.
	
//mesa vazia = jogando maior peça
+!start
	: not dominosontable(_) & not temDoble(V)
	<-
		?temMaiorPeca(domino(A,B),11);
		//put(domino(A,B),r);
		.print("MESA VAZIA - jogando a maior peça -> ", domino(A,B));
		//-domino(A,B);
	.

////mesa com peça - jogando a MAIOR PEÇA (TÁTICA)
//+!start
//	: dominosontable(LIST) & 
//	  consultaMesaLadoDireito(LIST,R) & 
//	  consultaMesaLadoEsquerdo(LIST,L) &
//	  consultaMaoMaiorPecaLadoDireito(R,DR) &
//	  consultaMaoMaiorPecaLadoEsquerdo(L,DL) &
//	  verificaMaiorPeca(DL,DR,domino(X,Y),LADO)
//	<-
////		put(domino(X,Y),LADO);
////		-domino(X,Y);
////		-domino(Y,X)
//		.print("MESA COM PEÇA - Jogando a maior peça -> ", domino(X,Y), " no lado ", LADO);
//	.

////mesa com peça - jogando a MAIOR PEÇA lado direito (TÁTICA)
//+!start
//	: dominosontable(LIST) & 
//	  consultaMesaLadoDireito(LIST,R) & 
//	  consultaMesaLadoEsquerdo(LIST,L) &
//	  consultaMaoMaiorPecaLadoDireito(R,domino(X,Y)) &
//	  consultaMaoMaiorPecaJogavelEsquerda(L,domino(C,D)) &
//	  ((X+Y) > (C+D))
//	<-
////		put(domino(X,Y),r);
////		-domino(X,Y);
////		-domino(Y,X)
//		.print("MESA COM PEÇA - Jogando a maior peça -> ", domino(X,Y), " no lado direito");
//	.
//	
////mesa com peça - jogando a MAIOR PEÇA lado esquerdo (TÁTICA)
//+!start
//	: dominosontable(LIST) & 
//	  consultaMesaLadoDireito(LIST,R) & 
//	  consultaMesaLadoEsquerdo(LIST,L) &
//	  consultaMaoMaiorPecaLadoDireito(R,domino(X,Y)) &
//	  consultaMaoMaiorPecaJogavelEsquerda(L,domino(C,D)) &
//	  ((X+Y) < (C+D))
//	<-
////		put(domino(C,D),l);
////		-domino(C,D);
////		-domino(D,C)
//		.print("MESA COM PEÇA - Jogando a maior peça -> ", domino(C,D), " no lado esquerdo");
//	.
//	
////mesa com peça - jogando a MAIOR PEÇA (LADOS IGUAIS) lado esquerdo (TÁTICA)
//+!start
//	: dominosontable(LIST) & 
//	  consultaMesaLadoDireito(LIST,R) & 
//	  consultaMesaLadoEsquerdo(LIST,L) &
//	  consultaMaoMaiorPecaLadoDireito(R,domino(X,Y)) &
//	  consultaMaoMaiorPecaJogavelEsquerda(L,domino(C,D)) &
//	  ((X+Y) == (C+D))
//	<-
////		put(domino(C,D),l);
////		-domino(C,D);
////		-domino(D,C)
//		.print("MESA COM PEÇA - Jogando peça VALORES IGUAIS  -> ", domino(C,D), " no lado direito");
//	.

+!start 
	: true
	<- 
		.print("deu ruim");
	.

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }