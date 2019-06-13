// Agent jjhon in project domino

/* CRENÇAS */

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

//se tem maior peça
temMaiorPeca(D,S):- domino(A,B) & D = domino(A,B).
temMaiorPeca(D,S):- S = A + B & temMaiorPeca(D,S-1).

//varrendo peças na mesa - numero do lado direto
consultaMesaLadoDireito(LIST,RETORNO):- LIST = [domino(A,B)] & RETORNO = B.
consultaMesaLadoDireito([H|T],RETORNO):- consultaMesaLadoDireito(T,RETORNO).

//varrendo peças na mesa - numero do lado esquerdo
consultaMesaLadoEsquerdo(LIST,RETORNO):- LIST = [domino(A,B)|T] & RETORNO = A.

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

//virando o domino
virarDomino(domino(A,B), DOMINO_VIRADO):- DOMINO_VIRADO = domino(B,A).

//consultando maior double
consultaMaoMaiorDoble(L,R,RETORNO,LADO):- L >= R & domino(L,L) & RETORNO = domino(L,L) & LADO = l.
consultaMaoMaiorDoble(L,R,RETORNO,LADO):- R >= L & domino(R,R) & RETORNO = domino(R,R) & LADO = r.

//consultando maior peça jogável para o lado direito
consultaMaoMaiorPecaLadoDireito(V,D):- domino(A,B) & A \== B & (A == V | B == V) & 
										not(domino(C,D) & C \== D & (C == V | D == V) & (C + D) > (A + B)) &
										(((A == V) & D = domino(A,B)) | ((B == V) & D = domino(B,A))).

//consultando maior peça jogável para o lado esquerdo
consultaMaoMaiorPecaLadoEsquerdo(V,D):- domino(A,B) & A \== B & (A == V | B == V) & 
										not(domino(C,D) & C \== D & (C == V | D == V) & (C + D) > (A + B)) &
										(((A == V) & D = domino(B,A)) | ((B == V) & D = domino(A,B))).

//verificando maior peça à ser jogada
verificaMaiorPeca(dominoEsquerda(A,B),dominoDireita(C,D),RETORNO,LADO):- (((A + B) > (C + D)) & RETORNO = domino(A,B) & LADO = l) |
																		 (RETORNO = domino(C,D) & LADO = r).

//////////////////////////////////////////////// TÁTICA 1 //////////////////////////////////////////////////
																		 
/*
 * MÉTODO AUXILIAR DA TÁTICA - "Sempre deixe as duas pontas passíveis de jogo para você"
 * Consulta a mão para verificar a quantidade de peças de uma determinada face
 * 
 * V - Valor da face
 * RETORNO - Retorna a quantidade de peças que possuem no mínimo uma face com esse valor
 */
consultaMaoContarExtremidade(V,RETORNO):- .count(domino(V,_),Quantidade) &
										  .count(domino(_,V),Quantidade2) &
										  RETORNO = Quantidade + Quantidade2.
										  
/*
 * MÉTODO AUXILIAR DA TÁTICA - "Sempre deixe as duas pontas passíveis de jogo para você"
 * Verifica a outra face para jogar a peça que tem também a maior quantidade de face 
 * 
 * N - Contador de 0 a 6
 * Face - Uma face do dominó, (em um domino(A,B), é a face A)
 * MelhorFace - A outra face do dominó, (em um domino(A,B), é a face B)
 * QtdMelhorFace - Quantidade de faces para verificar a melhor peça a ser jogada
 * RETORNO - Escolhe a melhor peça à ser jogada com base na tática
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
 * TÁTICA - "Sempre deixe as duas pontas passíveis de jogo para você"
 * Domino - Retorna a melhor peça para ser jogada com base na tática
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

////////////////////////////////////////////// FIM TÁTICA 1 //////////////////////////////////////////////////

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
	
//mesa com peça = jogando MAIOR DOBLE (TÁTICA)
+!jogar
	: dominosontable(LIST) & consultaMesaLadoDireito(LIST,R) & consultaMesaLadoEsquerdo(LIST,L) & consultaMaoMaiorDoble(L,R,RETORNO,LADO)
	<-
		put(RETORNO,LADO);
		.print("MESA COM PEÇA - Jogando o maior doble -> ", RETORNO, " no lado ", LADO);
		-RETORNO;
	.
	
//TÁTICA - Sempre deixe as duas pontas passíveis de jogo para você
+!jogar
	: verificarPontaDomino(Domino, Lado) & desconstroiDomino(Domino,A,B)
	<-
		.print("ENTROU");
		put(Domino, Lado);
		.print("MESA COM PEÇA - TÁTICA 1 -> ", Domino, " no lado ", Lado);
		-domino(A,B);
		-domino(B,A);
	.
	
////mesa com peça - jogando a MAIOR PEÇA (TÁTICA)
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
//		.print("MESA COM PEÇA - Jogando a maior peça -> ", domino(X,Y), " no lado ", LADO);
//	.

////mesa com peça - jogando a MAIOR PEÇA lado direito (TÁTICA)
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
//		.print("MESA COM PEÇA - Jogando a maior peça -> ", domino(X,Y), " no lado direito");
//	.
//	
////mesa com peça - jogando a MAIOR PEÇA lado esquerdo (TÁTICA)
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
//		.print("MESA COM PEÇA - Jogando a maior peça -> ", domino(C,D), " no lado esquerdo");
//	.
//	
////mesa com peça - jogando a MAIOR PEÇA (LADOS IGUAIS) lado esquerdo (TÁTICA)
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
//		.print("MESA COM PEÇA - Jogando peça VALORES IGUAIS  -> ", domino(C,D), " no lado direito");
//	.
//
//
////mesa com peça = jogando peça lado direito
//+!jogar
//	: dominosontable(LIST) & consultaMesaLadoDireito(LIST,R) & consultaMao(R,right,DOMINO_ACHADO,DOMINO)
//	<-
//		put(DOMINO_ACHADO,r);
//		.print("MESA COM PEÇA - Jogando a peça no lado direito -> ", DOMINO_ACHADO);
//		-DOMINO;
//	.
//
////mesa com peça = jogando peça lado esquerdo
//+!jogar
//	: dominosontable(LIST) & consultaMesaLadoEsquerdo(LIST,R) & consultaMao(R,left,DOMINO_ACHADO,DOMINO)
//	<-
//		put(DOMINO_ACHADO,l);
//		.print("MESA COM PEÇA - Jogando a peça no lado esquerdo -> ", DOMINO_ACHADO);
//		-DOMINO;
//	.

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
