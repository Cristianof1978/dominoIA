// Agent sample_agent in project domino

/* Initial beliefs and rules */

domino(0,1).
domino(1,2).
domino(2,4).
domino(2,5).
domino(4,4).

dominosontable([domino(6,6)]).

/* Initial goals */

//varrendo peças na mesa - numero do lado direto
consultaMesaLadoDireito(LIST,RETORNO):- LIST = [domino(A,B)] & RETORNO = B.
consultaMesaLadoDireito([H|T],RETORNO):- consultaMesaLadoDireito(T,RETORNO).

//varrendo peças na mesa - numero do lado esquerdo
consultaMesaLadoEsquerdo(LIST,RETORNO):- LIST = [domino(A,B)|T] & RETORNO = A.

desmontaDomino(domino(X,Y),A,B):- A = X & B = Y.

virarDomino(domino(A,B), DOMINO_VIRADO):- DOMINO_VIRADO = domino(B,A).

consultaMaoContarExtremidade(V,RETORNO)
			:- 
				.count(domino(V,_),Quantidade) &
				.count(domino(_,V),Quantidade2) &
				RETORNO = Quantidade + Quantidade2
			.
																						
escolhePecaJogar(Face,N,MelhorFace,QtdMelhorFace,RETORNO):- .print("----------> ",N) & N==7 & RETORNO = domino(Face,MelhorFace).
escolhePecaJogar(Face,N,MelhorFace,QtdMelhorFace,RETORNO)
			:- 
				.count(domino(Face,N),RD) &
				.count(domino(N,Face),RE) &
				.print("Domino ",Face,"|",N," - Melhor face ",MelhorFace) &
				(
					.print("QtdMelhorFace ",QtdMelhorFace," | RD= ",RD," RE= ", RE) &
					(RD > 0 | RE > 0) & Face\==N & consultaMaoContarExtremidade(N,X) & .print("  X ",X) &
					X > QtdMelhorFace & escolhePecaJogar(Face,N+1,N,X,RETORNO)
				) | 
				(
					.print("Aumentando N") &
					(RD == 0 | RE == 0 | Face==N) & escolhePecaJogar(Face,N + 1,MelhorFace,QtdMelhorFace,RETORNO)
				).

verificarPontaDomino(RETORNO,Lado)
			:- 
				dominosontable(LIST) &
				consultaMesaLadoEsquerdo(LIST,E) & 
				consultaMesaLadoDireito(LIST,D) &
				consultaMaoContarExtremidade(E,Quantidade) &
				consultaMaoContarExtremidade(D,Quantidade2) &
				.print("Ponta ",E," tem ",Quantidade," peças na mão") &
				.print("Ponta ",D," tem ",Quantidade2," peças na mão") &
				(
					(
						(
							Quantidade == 0 & Quantidade2 == 0 & .print("Jogador nao tem peça") & false
								| 
							( Quantidade >= Quantidade2 & Quantidade \== 0 &  Quantidade2 \== 0 & 
								escolhePecaJogar(E,0,0,0,domino(A,B)) & Lado = l & viraDominoSeNecessario( domino(A,B), Lado, E, DOMINOVIRADO ) 
							)
						)
							| 
						(
							Quantidade < Quantidade2 & escolhePecaJogar(D,0,0,0,domino(A,B)) & Lado = r & viraDominoSeNecessario( domino(A,B), Lado, D, DOMINOVIRADO )
						)
					) & .print( "A:", A, ",B:", B) & .print(DOMINOVIRADO) & RETORNO= DOMINOVIRADO
				)
				
			.
									
viraDominoSeNecessario( domino(A,B), LADO, PONTA, DOMINOVIRADO )
			:- 
				LADO == l & PONTA == B & DOMINOVIRADO = domino(A,B) & .print( "não virou") | 
				LADO == l & PONTA == A & virarDomino( domino(A,B), DOMINOVIRADO ) & .print( "virou") |
				LADO == r & PONTA == A & DOMINOVIRADO = domino(A,B) & .print( "não virou") |
				LADO == r & PONTA == B & virarDomino( domino(A,B), DOMINOVIRADO ) & .print( "virou")
			.

!start.

/* Plans */

+!start 
	:  verificarPontaDomino(Domino, Lado)
	<- 
		.print(Domino, " Lado ", Lado);
	.

+!start 
	: true
	<- 
		.print("deu ruim");
	.

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }