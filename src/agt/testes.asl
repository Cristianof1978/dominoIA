// Agent jjhon in project domino

/* CREN�AS */

dominosParaComprar(14).

/* REGRAS */

//desmonta o domino
desconstroiDomino(domino(X,Y),A,B):- A=X & B=Y.

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

//virando o domino
virarDomino(domino(A,B), DOMINO_VIRADO):- DOMINO_VIRADO = domino(B,A).

//consultando maior double
consultaMaoMaiorDoble(L,R,RETORNO,LADO):- L >= R & domino(L,L) & RETORNO = domino(L,L) & LADO = l.
consultaMaoMaiorDoble(L,R,RETORNO,LADO):- R >= L & domino(R,R) & RETORNO = domino(R,R) & LADO = r.

//consultando maior pe�a jog�vel para o lado direito
consultaMaoMaiorPecaLadoDireito(V,D):- domino(A,B) & A \== B & (A == V | B == V) & 
										not(domino(C,D) & C \== D & (C == V | D == V) & (C + D) > (A + B)) &
										(((A == V) & D = domino(A,B)) | ((B == V) & D = domino(B,A))).

//consultando maior pe�a jog�vel para o lado esquerdo
consultaMaoMaiorPecaLadoEsquerdo(V,D):- domino(A,B) & A \== B & (A == V | B == V) & 
										not(domino(C,D) & C \== D & (C == V | D == V) & (C + D) > (A + B)) &
										(((A == V) & D = domino(B,A)) | ((B == V) & D = domino(A,B))).

//verificando maior pe�a � ser jogada
verificaMaiorPeca(dominoEsquerda(A,B),dominoDireita(C,D),RETORNO,LADO):- (((A + B) > (C + D)) & RETORNO = domino(A,B) & LADO = l) |
																		 (RETORNO = domino(C,D) & LADO = r).

//////////////////////////////////////////////// T�TICA 1 //////////////////////////////////////////////////
																		 
/*
 * M�TODO AUXILIAR DA T�TICA - "Sempre deixe as duas pontas pass�veis de jogo para voc�"
 * Consulta a m�o para verificar a quantidade de pe�as de uma determinada face
 * 
 * V - Valor da face
 * RETORNO - Retorna a quantidade de pe�as que possuem no m�nimo uma face com esse valor
 */
consultaMaoContarExtremidade(V,RETORNO):- .count(domino(V,_),Quantidade) &
										  .count(domino(_,V),Quantidade2) &
										  RETORNO = Quantidade + Quantidade2.
										  
/*
 * M�TODO AUXILIAR DA T�TICA - "Sempre deixe as duas pontas pass�veis de jogo para voc�"
 * Verifica a outra face para jogar a pe�a que tem tamb�m a maior quantidade de face 
 * 
 * N - Contador de 0 a 6
 * Face - Uma face do domin�, (em um domino(A,B), � a face A)
 * MelhorFace - A outra face do domin�, (em um domino(A,B), � a face B)
 * QtdMelhorFace - Quantidade de faces para verificar a melhor pe�a a ser jogada
 * RETORNO - Escolhe a melhor pe�a � ser jogada com base na t�tica
 */											
escolhePecaJogar
	(Face,N,MelhorFace,QtdMelhorFace,RETORNO):- .print("----------> ",N) & N==7 & RETORNO = domino(Face,MelhorFace).
escolhePecaJogar
	(Face,N,MelhorFace,QtdMelhorFace,RETORNO):- .count(domino(Face,N),R0) &
												.count(domino(N,Face),R1) &
												.print("Face ",Face," Melhor face ",MelhorFace, " N ",N) &
												(
													.print(" N ",N," QtdMelhorFace ",QtdMelhorFace,"| RA= ",R0," RB= ", R1)&
													(R0 > 0 | R1 > 0) & Face\==N & consultaMaoContarExtremidade(N,X) & .print("  X ",X) &
													X > QtdMelhorFace & escolhePecaJogar(Face,N+1,N,X,RETORNO)
												) 
													| 
												(
													.print("Aumentando N") &
													(R0 == 0 | R1 == 0 | Face==N) & escolhePecaJogar(Face,N + 1,MelhorFace,QtdMelhorFace,RETORNO)		
												).
																		 
/*
 * T�TICA - "Sempre deixe as duas pontas pass�veis de jogo para voc�"
 * Domino - Retorna a melhor pe�a para ser jogada com base na t�tica
 * Lado - Determina o lado a ser jogado
 */
verificarPontaDomino(Domino,Lado) :- 
								dominosontable(LIST)&
								consultaMesaLadoEsquerdo(LIST,E) & 
								consultaMesaLadoDireito(LIST,D) &
								consultaMaoContarExtremidade(E,Quantidade) &
								consultaMaoContarExtremidade(D,Quantidade2) &
								.print(E," ",D)&
								(
									(Quantidade >= Quantidade2 & escolhePecaJogar(E,0,0,0,Domino) & Lado = l) | 
									(Quantidade < Quantidade2 & escolhePecaJogar(D,0,0,0,Domino) & Lado = r)
								)
								.

////////////////////////////////////////////// FIM T�TICA 1 //////////////////////////////////////////////////

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
	
//mesa com pe�a = jogando MAIOR DOBLE (T�TICA)
+!jogar
	: dominosontable(LIST) & consultaMesaLadoDireito(LIST,R) & consultaMesaLadoEsquerdo(LIST,L) & consultaMaoMaiorDoble(L,R,RETORNO,LADO)
	<-
		put(RETORNO,LADO);
		.print("MESA COM PE�A - Jogando o maior doble -> ", RETORNO, " no lado ", LADO);
		-RETORNO;
	.
	
//T�TICA - Sempre deixe as duas pontas pass�veis de jogo para voc�
+!jogar
	: verificarPontaDomino(Domino, Lado) & desconstroiDomino(Domino,A,B)
	<-
		.print("ENTROU");
		put(Domino, Lado);
		.print("MESA COM PE�A - T�TICA 1 -> ", Domino, " no lado ", Lado);
		-domino(A,B);
		-domino(B,A);
	.
	
////mesa com pe�a - jogando a MAIOR PE�A (T�TICA)
//+!jogar
//	: dominosontable(LIST) & 
//	  consultaMesaLadoDireito(LIST,R) & 
//	  consultaMesaLadoEsquerdo(LIST,L) &
//	  consultaMaoMaiorPecaLadoDireito(R,DR) &
//	  consultaMaoMaiorPecaLadoEsquerdo(L,DL) &
//	  verificaMaiorPeca(DL,DR,domino(X,Y),LADO)
//	<-
//		put(domino(X,Y),LADO);
//		-domino(X,Y);
//		-domino(Y,X)
//		.print("MESA COM PE�A - Jogando a maior pe�a -> ", domino(X,Y), " no lado ", LADO);
//	.

////mesa com pe�a - jogando a MAIOR PE�A lado direito (T�TICA)
//+!jogar
//	: dominosontable(LIST) & 
//	  consultaMesaLadoDireito(LIST,R) & 
//	  consultaMesaLadoEsquerdo(LIST,L) &
//	  consultaMaoMaiorPecaLadoDireito(R,domino(X,Y)) &
//	  consultaMaoMaiorPecaLadoEsquerdo(L,domino(C,D)) &
//	  ((X+Y) > (C+D))
//	<-
//		put(domino(X,Y),r);
//		-domino(X,Y);
//		-domino(Y,X)
//		.print("MESA COM PE�A - Jogando a maior pe�a -> ", domino(X,Y), " no lado direito");
//	.
//	
////mesa com pe�a - jogando a MAIOR PE�A lado esquerdo (T�TICA)
//+!jogar
//	: dominosontable(LIST) & 
//	  consultaMesaLadoDireito(LIST,R) & 
//	  consultaMesaLadoEsquerdo(LIST,L) &
//	  consultaMaoMaiorPecaLadoDireito(R,domino(X,Y)) &
//	  consultaMaoMaiorPecaLadoEsquerdo(L,domino(C,D)) &
//	  ((X+Y) < (C+D))
//	<-
//		put(domino(C,D),l);
//		-domino(C,D);
//		-domino(D,C)
//		.print("MESA COM PE�A - Jogando a maior pe�a -> ", domino(C,D), " no lado esquerdo");
//	.
//	
////mesa com pe�a - jogando a MAIOR PE�A (LADOS IGUAIS) lado esquerdo (T�TICA)
//+!jogar
//	: dominosontable(LIST) & 
//	  consultaMesaLadoDireito(LIST,R) & 
//	  consultaMesaLadoEsquerdo(LIST,L) &
//	  consultaMaoMaiorPecaLadoDireito(R,domino(X,Y)) &
//	  consultaMaoMaiorPecaLadoEsquerdo(L,domino(C,D)) &
//	  ((X+Y) == (C+D))
//	<-
//		put(domino(C,D),l);
//		-domino(C,D);
//		-domino(D,C)
//		.print("MESA COM PE�A - Jogando pe�a VALORES IGUAIS  -> ", domino(C,D), " no lado direito");
//	.
//
//
////mesa com pe�a = jogando pe�a lado direito
//+!jogar
//	: dominosontable(LIST) & consultaMesaLadoDireito(LIST,R) & consultaMao(R,right,DOMINO_ACHADO,DOMINO)
//	<-
//		put(DOMINO_ACHADO,r);
//		.print("MESA COM PE�A - Jogando a pe�a no lado direito -> ", DOMINO_ACHADO);
//		-DOMINO;
//	.
//
////mesa com pe�a = jogando pe�a lado esquerdo
//+!jogar
//	: dominosontable(LIST) & consultaMesaLadoEsquerdo(LIST,R) & consultaMao(R,left,DOMINO_ACHADO,DOMINO)
//	<-
//		put(DOMINO_ACHADO,l);
//		.print("MESA COM PE�A - Jogando a pe�a no lado esquerdo -> ", DOMINO_ACHADO);
//		-DOMINO;
//	.

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
