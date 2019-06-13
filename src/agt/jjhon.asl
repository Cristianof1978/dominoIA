// Agent jjhon in project domino

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

//////////////////////////////////// AUXILIARES AMBAS AS TÁTICAS ////////////////////////////////////

//varrendo peças na mesa - numero do lado direto
consultaMesaLadoDireito(LIST,RETORNO):- LIST = [domino(A,B)] & RETORNO = B.
consultaMesaLadoDireito([H|T],RETORNO):- consultaMesaLadoDireito(T,RETORNO).

//varrendo peças na mesa - numero do lado esquerdo
consultaMesaLadoEsquerdo(LIST,RETORNO):- LIST = [domino(A,B)|T] & RETORNO = A.

//virando o domino
virarDomino(domino(A,B), DOMINO_VIRADO):- DOMINO_VIRADO = domino(B,A).

//////////////////////////////////// FIM AUXILIARES AMBAS AS TÁTICAS ////////////////////////////////////

//////////////////////////////////////////////// TÁTICA 1 //////////////////////////////////////////////////

/*
 * AUXILIAR DA TÁTICA - "Jogue sempre primeiro as maiores carroças"
 * Consulta a mão para encontrar o maior doble à jogar no lado direito e depois lado esquerdo
 * 
 * L - Lado esquerdo
 * R - Lado direito
 * RETORNO - Retorna a maior carroça
 * LADO - Retorna o lado à ser jogado
 */
consultaMaoMaiorDoble(L,R,RETORNO,LADO):- L >= R & domino(L,L) & RETORNO = domino(L,L) & LADO = l.
consultaMaoMaiorDoble(L,R,RETORNO,LADO):- R >= L & domino(R,R) & RETORNO = domino(R,R) & LADO = r.

/*
 * TÁTICA - "Jogue sempre primeiro as maiores carroças"
 * Realiza consulta pela maior carroça na mão
 * 
 * RETORNO - Retorna o maior doble
 * LADO - retorna o lado à ser jogado
 */
consultaMaoMaiorCarroca(RETORNO,LADO):- dominosontable(LIST) &
							   		 	consultaMesaLadoEsquerdo(LIST,L) & 
							   		 	consultaMesaLadoDireito(LIST,R) &
							   		 	consultaMaoMaiorDoble(L,R,RETORNO,LADO).

//////////////////////////////////////////////// FIM TÁTICA 1 //////////////////////////////////////////////////

//////////////////////////////////////////////// TÁTICA 2 //////////////////////////////////////////////////
																		 
/*
 * AUXILIAR DA TÁTICA - "Sempre deixe as duas pontas passíveis de jogo para você"
 * Consulta a mão para verificar a quantidade de peças de uma determinada face
 * 
 * V - Valor da face
 * RETORNO - Retorna a quantidade de peças que possuem no mínimo uma face com esse valor
 */
consultaMaoContarExtremidade(V,RETORNO)
			:-
				.count(domino(V,_),Quantidade) &
				.count(domino(_,V),Quantidade2) &
				RETORNO = Quantidade + Quantidade2
			.
										  
/*
 * AUXILIAR DA TÁTICA - "Sempre deixe as duas pontas passíveis de jogo para você"
 * Verifica a outra face para jogar a peça que tem também a maior quantidade de face 
 * 
 * N - Contador de 0 a 6
 * Face - Uma face do dominó, (em um domino(A,B), é a face A)
 * MelhorFace - A outra face do dominó, (em um domino(A,B), é a face B)
 * QtdMelhorFace - Quantidade de faces para verificar a melhor peça a ser jogada
 * RETORNO - Escolhe a melhor peça à ser jogada com base na tática
 */											
escolhePecaJogar(Face,N,MelhorFace,QtdMelhorFace,RETORNO):- N==7 & RETORNO = domino(Face,MelhorFace).
escolhePecaJogar(Face,N,MelhorFace,QtdMelhorFace,RETORNO)
			:-
				.count(domino(Face,N),R0) &
				.count(domino(N,Face),R1) &
				(
					(R0 > 0 | R1 > 0) & 
					consultaMaoContarExtremidade(N,X) &
					X > QtdMelhorFace & escolhePecaJogar(Face,N+1,N,X,RETORNO)
				) 
					| 
				(
					(R0 == 0 | R1 == 0 | Face==N) & escolhePecaJogar(Face,N + 1,MelhorFace,QtdMelhorFace,RETORNO)		
				)
			.
/*
 * AUXILIAR DA TÁTICA - "Sempre deixe as duas pontas passíveis de jogo para você"
 * Apenas desmonta as faces do dominó para retirar das crenças o domino inverso
 * domino(X,Y) - um domino qualquer
 * A e B são as faces desmontadas do domino
 */												
desmontaDomino(domino(X,Y),A,B):- A = X & B = Y.	

/*
 * AUXILIAR DA TÁTICA - "Sempre deixe as duas pontas passíveis de jogo para você"
 * Vira o dominó se necessário
 * domino(A,B) - dominó
 * LADO - lado da mesa
 * PONTA - ponta da mesa
 * DOMINOVIRADO - Retorna um dominó virado
 */
viraDominoSeNecessario( domino(A,B), LADO, PONTA, DOMINOVIRADO )
			:- 
				LADO == l & PONTA == B & DOMINOVIRADO = domino(A,B) | 
				LADO == l & PONTA == A & virarDomino( domino(A,B), DOMINOVIRADO )|
				LADO == r & PONTA == A & DOMINOVIRADO = domino(A,B) |
				LADO == r & PONTA == B & virarDomino( domino(A,B), DOMINOVIRADO )
			.
			
/*
 * TÁTICA - "Sempre deixe as duas pontas passíveis de jogo para você"
 * Domino - Retorna a melhor peça para ser jogada com base na tática
 * Lado - Determina o lado a ser jogado
 */
verificarPontaDomino(RETORNO,Lado)
			:- 
				dominosontable(LIST) &
				consultaMesaLadoEsquerdo(LIST,E) & 
				consultaMesaLadoDireito(LIST,D) &
				consultaMaoContarExtremidade(E,Quantidade) &
				consultaMaoContarExtremidade(D,Quantidade2) &
				(
					(
						(
						(	Quantidade == 0 & Quantidade2 == 0 & false | 
							( Quantidade >= Quantidade2 & ( Quantidade \== 0 |  Quantidade2 \== 0 ) & 
								escolhePecaJogar(E,0,0,0,domino(A,B)) & Lado = l & viraDominoSeNecessario( domino(A,B), Lado, E, DOMINOVIRADO ) )
						) | 
						(Quantidade < Quantidade2 & escolhePecaJogar(D,0,0,0,domino(A,B)) & Lado = r & viraDominoSeNecessario( domino(A,B), Lado, D, DOMINOVIRADO ))
						) 
						& RETORNO= DOMINOVIRADO
					)
				)
				
			.
			
////////////////////////////////////////////// FIM TÁTICA 2 //////////////////////////////////////////////////

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
		-domino(A,B);
	.
	
//mesa vazia = jogando maior peça
+!jogar
	: not dominosontable(_) & not temDoble(V)
	<-
		?temMaiorPeca(domino(A,B),11);
		put(domino(A,B),r);
		-domino(A,B);
	.
	  	
//TÁTICA 1 - Jogue primeiro as maiores carroças
+!jogar
	: consultaMaoMaiorCarroca(RETORNO,LADO)
	<-
		put(RETORNO,LADO);
		-RETORNO;
	.
	
//TÁTICA 2 - Sempre deixe as duas pontas passíveis de jogo para você
+!jogar
	: verificarPontaDomino(Domino, Lado) & desmontaDomino(Domino,A,B)
	<-
		put(Domino, Lado);
		-domino(A,B);
		-domino(B,A);
	.

//não tenho peça de encaixe e preciso comprar
+!jogar
	: dominosParaComprar(X) & X > 0
	<-
		getdomino(Domino);
		+Domino;
		!jogar;
	.
	
//nao tenho peça de encaixe e não tem peça pra comprar entao PASSEI A VEZ
+!jogar
	: dominosParaComprar(X) & X == 0
	<-
		passturn;
	.
	

-!jogar
	: true
	<- 
		true
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