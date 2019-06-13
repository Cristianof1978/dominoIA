// Agent dummie in project domino

/* CREN�AS */

dominosParaComprar(14).

/* REGRAS */

//se tem doble
temDoble(V):- domino(X,X) & V = true.
temDoble(V):- not domino(X,X) & V = false.

//sem tem maior doble
temMaiorDoble(D,X):- domino(X,X) & D = domino(X,X).
temMaiorDoble(D,X):- temMaiorDoble(D,X-1).

//se tem maior pe�a
temMaiorPeca(D,S):- domino(A,B) & D = domino(A,B).
temMaiorPeca(D,S):- S = A + B & temMaiorPeca(D,S-1).

//varrendo pe�as na mesa - numero do lado direto
consultaMesaLadoDireito(LIST,RETORNO):- LIST = [domino(A,B)] & RETORNO = B.
consultaMesaLadoDireito([H|T],RETORNO):- consultaMesaLadoDireito(T,RETORNO).

//varrendo pe�as na mesa - numero do lado esquerdo
consultaMesaLadoEsquerdo(LIST,RETORNO):- LIST = [domino(A,B)|T] & RETORNO = A.

//virando o domino
virarDomino(domino(A,B), DOMINO_VIRADO):- DOMINO_VIRADO = domino(B,A).

/* 
 * Varrendo a m�o para encontrar a pe�a que encaixa na mesa e rotando se necess�rio
 * V = valor da pe�a que procura
 * L = lado da mesa
 * D = domino que ser� retornado
 * AUX = domino n�o virado para ser exclu�do das cren�as ao ser jogado
 */
consultaMao(V,L,D,AUX):- domino(A,B) & (
	A = V & L = right & D = domino(A,B) & AUX = domino(A,B) |
	A = V & L = left & virarDomino(domino(A,B),RETORNO) & D = RETORNO  & AUX = domino(A,B) |
	B = V & L = right & virarDomino(domino(A,B),RETORNO) & D = RETORNO & AUX = domino(A,B) |
	B = V & L = left & D = domino(A,B) & AUX = domino(A,B)
).

!start.

/* PLANOS */

//hand pra receber a m�o
+hand(Domino)
	: true
	<-
		+Domino;
	.

//a��o de jogar
+playerturn(Ag)
	: .my_name(Ag) & not win(_)
	<-
		!jogar
	.

//n�o � o turno do jogador
+playerturn(Ag)
	: not .my_name(Ag) & not win(_)
	<-
		true
	.

//sinaliza se algum jogador comprou pe�a
+peeked
	: true
	<-
		!decrementarDominosParaComprar;
	.

//iniciando a aplica��o
+!start 
	: true
	<- 
		join;
	.
	
//mesa vazia = jogando maior doble
+!jogar
	: not dominosontable(_) & temDoble(V)
	<-
		?temMaiorDoble(domino(A,B),6);
		put(domino(A,B),r);
		.print("MESA VAZIA - jogando maior doble -> ", domino(A,B));
		-domino(A,B);
	.
	
//mesa vazia = jogando maior pe�a
+!jogar
	: not dominosontable(_) & not temDoble(V)
	<-
		?temMaiorPeca(domino(A,B),11);
		put(domino(A,B),r);
		.print("MESA VAZIA - jogando a maior pe�a -> ", domino(A,B));
		-domino(A,B);
	.
	
//mesa com pe�a = jogando pe�a lado direito
+!jogar
	: dominosontable(LIST) & consultaMesaLadoDireito(LIST,R) & consultaMao(R,right,DOMINO_ACHADO,DOMINO)
	<-
		put(DOMINO_ACHADO,r);
		.print("MESA COM PE�A - Jogando a pe�a no lado direito -> ", DOMINO_ACHADO);
		-DOMINO;
	.

//mesa com pe�a = jogando pe�a lado esquerdo
+!jogar
	: dominosontable(LIST) & consultaMesaLadoEsquerdo(LIST,R) & consultaMao(R,left,DOMINO_ACHADO,DOMINO)
	<-
		put(DOMINO_ACHADO,l);
		.print("MESA COM PE�A - Jogando a pe�a no lado esquerdo -> ", DOMINO_ACHADO);
		-DOMINO;
	.

//n�o tenho pe�a de encaixe e preciso comprar
+!jogar
	: dominosParaComprar(X) & X > 0
	<-
		.print("COMPREI");
		getdomino(Domino);
		+Domino;
		!jogar;
	.
	
//nao tenho pe�a de encaixe e n�o tem pe�a pra comprar entao PASSEI A VEZ
+!jogar
	: dominosParaComprar(X) & X == 0
	<-
		.print("PASSEI A VEZ");
		passturn;
	.
	

-!jogar
	: true
	<- 
		.print("Deu ruim");
	.

//controle de pe�as para comprar
+!decrementarDominosParaComprar 
	: true
	<-
		?dominosParaComprar(X);
		-dominosParaComprar(_);
		+dominosParaComprar(X - 1);
	.

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
