// Agent dummie in project domino

/* CRENÇAS */

dominosParaComprar(14).

/* REGRAS */

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

//virando o domino
virarDomino(domino(A,B), DOMINO_VIRADO):- DOMINO_VIRADO = domino(B,A).

/* 
 * Varrendo a mão para encontrar a peça que encaixa na mesa e rotando se necessário
 * V = valor da peça que procura
 * L = lado da mesa
 * D = domino que será retornado
 * AUX = domino não virado para ser excluído das crenças ao ser jogado
 */
consultaMao(V,L,D,AUX):- domino(A,B) & (
	A = V & L = right & D = domino(A,B) & AUX = domino(A,B) |
	A = V & L = left & virarDomino(domino(A,B),RETORNO) & D = RETORNO  & AUX = domino(A,B) |
	B = V & L = right & virarDomino(domino(A,B),RETORNO) & D = RETORNO & AUX = domino(A,B) |
	B = V & L = left & D = domino(A,B) & AUX = domino(A,B)
).

!start.

/* PLANOS */

//hand pra receber a mão
+hand(Domino)
	: true
	<-
		+Domino;
	.

//ação de jogar
+playerturn(Ag)
	: .my_name(Ag) & not win(_)
	<-
		!jogar
	.

//não é o turno do jogador
+playerturn(Ag)
	: not .my_name(Ag) & not win(_)
	<-
		true
	.

//sinaliza se algum jogador comprou peça
+peeked
	: true
	<-
		!decrementarDominosParaComprar;
	.

//iniciando a aplicação
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
	
//mesa vazia = jogando maior peça
+!jogar
	: not dominosontable(_) & not temDoble(V)
	<-
		?temMaiorPeca(domino(A,B),11);
		put(domino(A,B),r);
		.print("MESA VAZIA - jogando a maior peça -> ", domino(A,B));
		-domino(A,B);
	.
	
//mesa com peça = jogando peça lado direito
+!jogar
	: dominosontable(LIST) & consultaMesaLadoDireito(LIST,R) & consultaMao(R,right,DOMINO_ACHADO,DOMINO)
	<-
		put(DOMINO_ACHADO,r);
		.print("MESA COM PEÇA - Jogando a peça no lado direito -> ", DOMINO_ACHADO);
		-DOMINO;
	.

//mesa com peça = jogando peça lado esquerdo
+!jogar
	: dominosontable(LIST) & consultaMesaLadoEsquerdo(LIST,R) & consultaMao(R,left,DOMINO_ACHADO,DOMINO)
	<-
		put(DOMINO_ACHADO,l);
		.print("MESA COM PEÇA - Jogando a peça no lado esquerdo -> ", DOMINO_ACHADO);
		-DOMINO;
	.

//não tenho peça de encaixe e preciso comprar
+!jogar
	: dominosParaComprar(X) & X > 0
	<-
		.print("COMPREI");
		getdomino(Domino);
		+Domino;
		!jogar;
	.
	
//nao tenho peça de encaixe e não tem peça pra comprar entao PASSEI A VEZ
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

//controle de peças para comprar
+!decrementarDominosParaComprar 
	: true
	<-
		?dominosParaComprar(X);
		-dominosParaComprar(_);
		+dominosParaComprar(X - 1);
	.

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
