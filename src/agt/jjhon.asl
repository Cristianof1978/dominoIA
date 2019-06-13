// Agent jjhon in project domino

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

//////////////////////////////////// AUXILIARES AMBAS AS T�TICAS ////////////////////////////////////

//varrendo pe�as na mesa - numero do lado direto
consultaMesaLadoDireito(LIST,RETORNO):- LIST = [domino(A,B)] & RETORNO = B.
consultaMesaLadoDireito([H|T],RETORNO):- consultaMesaLadoDireito(T,RETORNO).

//varrendo pe�as na mesa - numero do lado esquerdo
consultaMesaLadoEsquerdo(LIST,RETORNO):- LIST = [domino(A,B)|T] & RETORNO = A.

//virando o domino
virarDomino(domino(A,B), DOMINO_VIRADO):- DOMINO_VIRADO = domino(B,A).

//////////////////////////////////// FIM AUXILIARES AMBAS AS T�TICAS ////////////////////////////////////

//////////////////////////////////////////////// T�TICA 1 //////////////////////////////////////////////////

/*
 * AUXILIAR DA T�TICA - "Jogue sempre primeiro as maiores carro�as"
 * Consulta a m�o para encontrar o maior doble � jogar no lado direito e depois lado esquerdo
 * 
 * L - Lado esquerdo
 * R - Lado direito
 * RETORNO - Retorna a maior carro�a
 * LADO - Retorna o lado � ser jogado
 */
consultaMaoMaiorDoble(L,R,RETORNO,LADO):- L >= R & domino(L,L) & RETORNO = domino(L,L) & LADO = l.
consultaMaoMaiorDoble(L,R,RETORNO,LADO):- R >= L & domino(R,R) & RETORNO = domino(R,R) & LADO = r.

/*
 * T�TICA - "Jogue sempre primeiro as maiores carro�as"
 * Realiza consulta pela maior carro�a na m�o
 * 
 * RETORNO - Retorna o maior doble
 * LADO - retorna o lado � ser jogado
 */
consultaMaoMaiorCarroca(RETORNO,LADO):- dominosontable(LIST) &
							   		 	consultaMesaLadoEsquerdo(LIST,L) & 
							   		 	consultaMesaLadoDireito(LIST,R) &
							   		 	consultaMaoMaiorDoble(L,R,RETORNO,LADO).

//////////////////////////////////////////////// FIM T�TICA 1 //////////////////////////////////////////////////

//////////////////////////////////////////////// T�TICA 2 //////////////////////////////////////////////////
																		 
/*
 * AUXILIAR DA T�TICA - "Sempre deixe as duas pontas pass�veis de jogo para voc�"
 * Consulta a m�o para verificar a quantidade de pe�as de uma determinada face
 * 
 * V - Valor da face
 * RETORNO - Retorna a quantidade de pe�as que possuem no m�nimo uma face com esse valor
 */
consultaMaoContarExtremidade(V,RETORNO)
			:-
				.count(domino(V,_),Quantidade) &
				.count(domino(_,V),Quantidade2) &
				RETORNO = Quantidade + Quantidade2
			.
										  
/*
 * AUXILIAR DA T�TICA - "Sempre deixe as duas pontas pass�veis de jogo para voc�"
 * Verifica a outra face para jogar a pe�a que tem tamb�m a maior quantidade de face 
 * 
 * N - Contador de 0 a 6
 * Face - Uma face do domin�, (em um domino(A,B), � a face A)
 * MelhorFace - A outra face do domin�, (em um domino(A,B), � a face B)
 * QtdMelhorFace - Quantidade de faces para verificar a melhor pe�a a ser jogada
 * RETORNO - Escolhe a melhor pe�a � ser jogada com base na t�tica
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
 * AUXILIAR DA T�TICA - "Sempre deixe as duas pontas pass�veis de jogo para voc�"
 * Apenas desmonta as faces do domin� para retirar das cren�as o domino inverso
 * domino(X,Y) - um domino qualquer
 * A e B s�o as faces desmontadas do domino
 */												
desmontaDomino(domino(X,Y),A,B):- A = X & B = Y.	

/*
 * AUXILIAR DA T�TICA - "Sempre deixe as duas pontas pass�veis de jogo para voc�"
 * Vira o domin� se necess�rio
 * domino(A,B) - domin�
 * LADO - lado da mesa
 * PONTA - ponta da mesa
 * DOMINOVIRADO - Retorna um domin� virado
 */
viraDominoSeNecessario( domino(A,B), LADO, PONTA, DOMINOVIRADO )
			:- 
				LADO == l & PONTA == B & DOMINOVIRADO = domino(A,B) | 
				LADO == l & PONTA == A & virarDomino( domino(A,B), DOMINOVIRADO )|
				LADO == r & PONTA == A & DOMINOVIRADO = domino(A,B) |
				LADO == r & PONTA == B & virarDomino( domino(A,B), DOMINOVIRADO )
			.
			
/*
 * T�TICA - "Sempre deixe as duas pontas pass�veis de jogo para voc�"
 * Domino - Retorna a melhor pe�a para ser jogada com base na t�tica
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
			
////////////////////////////////////////////// FIM T�TICA 2 //////////////////////////////////////////////////

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
		-domino(A,B);
	.
	
//mesa vazia = jogando maior pe�a
+!jogar
	: not dominosontable(_) & not temDoble(V)
	<-
		?temMaiorPeca(domino(A,B),11);
		put(domino(A,B),r);
		-domino(A,B);
	.
	  	
//T�TICA 1 - Jogue primeiro as maiores carro�as
+!jogar
	: consultaMaoMaiorCarroca(RETORNO,LADO)
	<-
		put(RETORNO,LADO);
		-RETORNO;
	.
	
//T�TICA 2 - Sempre deixe as duas pontas pass�veis de jogo para voc�
+!jogar
	: verificarPontaDomino(Domino, Lado) & desmontaDomino(Domino,A,B)
	<-
		put(Domino, Lado);
		-domino(A,B);
		-domino(B,A);
	.

//n�o tenho pe�a de encaixe e preciso comprar
+!jogar
	: dominosParaComprar(X) & X > 0
	<-
		getdomino(Domino);
		+Domino;
		!jogar;
	.
	
//nao tenho pe�a de encaixe e n�o tem pe�a pra comprar entao PASSEI A VEZ
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