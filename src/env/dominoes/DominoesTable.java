// CArtAgO artifact code for project teste

package dominoes;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Stack;

import cartago.*;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.Literal;
import jason.asSyntax.parser.ParseException;

public class DominoesTable extends Artifact {
	AgentId [] players = new AgentId [2];
	int handlerPlayers = 0;
	Domino initialDomino;
	DominoesTableView DominoesView;
		
	ArrayList [] playersHands = new ArrayList [2]; 	
	Stack<Domino> sleepDominos = new Stack<Domino>();	
	ArrayList <Domino> dominoOnTable = new ArrayList <Domino>();

	@OPERATION 
	void init () {
		DominoesView = new DominoesTableView(); 
		
		Domino [] tmpBlk = {	new Domino(0,0), new Domino(0,1),
							new Domino(0,2), new Domino(0,3),
							new Domino(0,4), new Domino(0,5), 
							new Domino(0,6), new Domino(1,1),
							new Domino(1,2), new Domino(1,3),
							new Domino(1,4), new Domino(1,5),
							new Domino(1,6), new Domino(2,2),
							new Domino(2,3), new Domino(2,4),
							new Domino(2,5), new Domino(2,6),
							new Domino(3,3), new Domino(3,4),
							new Domino(3,5), new Domino(3,6),
							new Domino(4,4), new Domino(4,5),
							new Domino(4,6), new Domino(5,5),
							new Domino(5,6), new Domino(6,6)};	
		for (Domino b:tmpBlk) 
			this.sleepDominos.push(b);
		
		this.playersHands[0]= new ArrayList<Domino>();
		this.playersHands[1]= new ArrayList<Domino>();
	}
	
	@OPERATION
	void join() {
		this.players[this.handlerPlayers]=getCurrentOpAgentId();
		this.handlerPlayers=(this.handlerPlayers+1)%2;
		if (this.handlerPlayers==0) {
			execInternalOp("start");
		}
	}
	@INTERNAL_OPERATION
	void start() throws ParseException {
		//shuffle dominos
		Collections.shuffle(this.sleepDominos);
		//initiate the players hands
		Domino dominoToStart= new Domino(-1,-2);
		int firstPlayer=-1;
		for (int i=0; i<2; i++)			
			for (int j=0; j<7; j++) {
				if ((dominoToStart.getvalues()[0]==dominoToStart.getvalues()[1] &&
					this.sleepDominos.peek().getvalues()[0]==this.sleepDominos.peek().getvalues()[1] &&
					dominoToStart.getvalues()[0]<this.sleepDominos.peek().getvalues()[0]) 
												||
					(dominoToStart.getvalues()[0]!=dominoToStart.getvalues()[1] &&
					this.sleepDominos.peek().getvalues()[0]==this.sleepDominos.peek().getvalues()[1])
												||
					(dominoToStart.getvalues()[0]!=dominoToStart.getvalues()[1] &&
					this.sleepDominos.peek().getvalues()[0]!=this.sleepDominos.peek().getvalues()[1] &&
					(dominoToStart.getvalues()[0]+dominoToStart.getvalues()[1])
						<(this.sleepDominos.peek().getvalues()[0]+this.sleepDominos.peek().getvalues()[1])))
					{
						dominoToStart=this.sleepDominos.peek();
						firstPlayer=i;
					}					
				this.playersHands[i].add(this.sleepDominos.pop());
			}	
		this.initialDomino=dominoToStart;
		//send initial hand dominos to the agents 
		for (int i=0; i<2; i++) 
			for (Object domino:this.playersHands[i]) {
				signal(this.players[i], "hand", ((Domino)domino).getLiteralDomino());	
			}	
		updatePlayerTurn(firstPlayer);
	}

	@OPERATION
	void put(String domino, String side) throws ParseException {
		await_time(1000);
		if (this.players[handlerPlayers].equals(getCurrentOpAgentId())) {
			Domino tmpB = new Domino(domino);
			if (locateDomino(tmpB)!=-1) {
				if (this.dominoOnTable.isEmpty()) {
					if (tmpB.equals(this.initialDomino)) {
						this.dominoOnTable.add(tmpB);
						DominoesView.setFirstDomino(tmpB.getvalues()[0],tmpB.getvalues()[1]);
						sucessfullPut(tmpB);						
					}
					else {
						System.out.println(this.initialDomino.getLiteralDomino().toString());
						failed("put failed","put_failed","Invalid domino! Try start the game with your higher double domino", tmpB.getLiteralDomino());
					}
					
				}
				else if (side.equals("l")) {			
						if (this.dominoOnTable.get(0).getvalues()[0] == tmpB.getvalues()[1])
						{
							this.dominoOnTable.add(0,tmpB);
							DominoesView.setNextLeftDomino(tmpB.getvalues()[0],tmpB.getvalues()[1]);
							sucessfullPut(tmpB);
						}
						else {
							failed("put failed","put_failed","Invalid domino!", tmpB.getLiteralDomino());
						}						
					}
				else if (side.equals("r")) {
					if (this.dominoOnTable.get(this.dominoOnTable.size()-1).getvalues()[1] == tmpB.getvalues()[0])
					{
						this.dominoOnTable.add(tmpB);
						DominoesView.setNextRightDomino(tmpB.getvalues()[0],tmpB.getvalues()[1]);
						sucessfullPut(tmpB);
					}
					else {
						failed("put failed","put_failed","Invalid domino!",tmpB.getLiteralDomino());
					}					
				}
				else {
					failed("put failed","put_failed","Invalid side!",side);
				}
			}
			else {
				failed("put failed","put_failed","You do not have this domino!",tmpB.getLiteralDomino());
			}
		}
		else {
			failed("put failed","put_failed","It is not your turn!");
		}
			
	}
	
	@OPERATION
	void getdomino (OpFeedbackParam<Literal> domino) {
		await_time(1000);
		if (this.players[handlerPlayers].equals(getCurrentOpAgentId())) {
			if (!this.sleepDominos.isEmpty()) {
				this.playersHands[this.handlerPlayers].add(this.sleepDominos.peek());
				domino.set(this.sleepDominos.pop().getLiteralDomino());
				signal("peeked");
				this.DominoesView.updateStatus( 
												this.players[0].getAgentName(),
												this.players[1].getAgentName(),
												this.playersHands[0].size(),
												this.playersHands[1].size(), 
												this.sleepDominos.size());
				this.DominoesView.appendLog(this.players[this.handlerPlayers].getAgentName()+" - get a Sleeping domino\n");
			}
			else {
				failed("getdomino failed","getdomino_failed","There no sleeping dominos, try pass the turn!");
			}	
		}	
		else {
			failed("put failed","put_failed","It is not your turn!");
		}
	}
	
	@OPERATION
	void passturn() throws ParseException {
		await_time(1000);
		if (this.players[handlerPlayers].equals(getCurrentOpAgentId())) {
			if (this.sleepDominos.isEmpty()) {
				updatePlayerTurn();
				this.DominoesView.updateStatus( 
												this.players[0].getAgentName(),
												this.players[1].getAgentName(),
												this.playersHands[0].size(),
												this.playersHands[1].size(), 
												this.sleepDominos.size());
				this.DominoesView.appendLog(this.players[this.handlerPlayers].getAgentName()+" - passed the turn\n");
			}
			else {
				failed("getdomino failed","getdomino_failed","There are sleeping dominos, try get a new domino!");
			}	
		}	
		else {
			failed("put failed","put_failed","It is not your turn!");
		}
	}

	
	private void updatePlayerTurn() throws ParseException {
		if (hasObsProperty("playerturn")) 
			removeObsProperty("playerturn");
		
		//check if the match is finished
		checkFinished();
		
		this.handlerPlayers=(this.handlerPlayers+1)%2;
		defineObsProperty("playerturn", ASSyntax.parseLiteral(
				this.players[this.handlerPlayers].getAgentName()));
	}
	
	private void updatePlayerTurn(int player) throws ParseException {
		if (hasObsProperty("playerturn")) 
			removeObsProperty("playerturn");
		
		this.handlerPlayers=player;
		defineObsProperty("playerturn", ASSyntax.parseLiteral(
				this.players[this.handlerPlayers].getAgentName()));
	}
	
	private void sucessfullPut(Domino b) throws ParseException {
		this.playersHands[this.handlerPlayers].remove(locateDomino(b));
		signal(this.players[this.handlerPlayers], "sucessfullput", b.getLiteralDomino());	
		this.DominoesView.appendLog(this.players[this.handlerPlayers].getAgentName()+" - put domino "+b.getLiteralDomino().toString()+"\n" );
		updateDominosTable();	
		updatePlayerTurn();			
		
	}
	
	private void checkFinished() throws ParseException {
		if (isEnded()) {			
			int countHand0 = countHand(0);			
			int countHand1 = countHand(1);
			if (countHand0<countHand1) {
				defineObsProperty("win", ASSyntax.parseLiteral(this.players[0].getAgentName()));
				this.DominoesView.appendLog(this.players[0].getAgentName()+" - wins!\n");
				this.DominoesView.endOFMatch("The player "+this.players[0].getAgentName()+" wins!");				
			}
			else if (countHand0>countHand1) {
				defineObsProperty("win", ASSyntax.parseLiteral(this.players[1].getAgentName()));
				this.DominoesView.appendLog(this.players[1].getAgentName()+" - wins!\n");
				this.DominoesView.endOFMatch("The player "+this.players[1].getAgentName()+" wins!");				
			}
			else {
				defineObsProperty("draw");
				this.DominoesView.appendLog("The match draws!\n");
				this.DominoesView.endOFMatch("The match draws!");
			}
			
		}
		
	}
	private void updateDominosTable () throws ParseException {
		this.DominoesView.updateStatus( this.players[0].getAgentName(),
										this.players[1].getAgentName(),
										this.playersHands[0].size(),
										this.playersHands[1].size(), 
										this.sleepDominos.size());
		if (hasObsProperty("dominosontable")) 
			removeObsProperty("dominosontable");
		defineObsProperty("dominosontable", ASSyntax.parseList(listToString(this.dominoOnTable)));
	}
	
	private  String listToString(ArrayList<Domino> l) throws ParseException {
		String tmp = "[";
		for (Domino b:l)
			if (tmp.equals("["))
				tmp+= b.getLiteralDomino().toString();
			else
				tmp+= ","+b.getLiteralDomino().toString();
		return tmp+"]";
	}
	
	private  int locateDomino(Domino b) {
		for (int i=0; i<this.playersHands[handlerPlayers].size();i++)
			if (((Domino)this.playersHands[handlerPlayers].get(i)).equals(b))
				return i;
		return -1;
	}
	
	
	private  int countHand(int player) {
		int count=0;
		for (Object domino: this.playersHands[player]) {
			count+= ((Domino)domino).getvalues()[0]+((Domino)domino).getvalues()[1];
		}
		return count;
	}
	
	private  boolean isEnded() {
		//if one players no has dominos
		if (this.playersHands[0].isEmpty() || this.playersHands[1].isEmpty() ) 
			return true;	
		else if(this.sleepDominos.isEmpty()) {			
			if (existsDomino(this.dominoOnTable.get(0).getvalues()[0], this.playersHands[0]) ||
				existsDomino(this.dominoOnTable.get(this.dominoOnTable.size()-1).getvalues()[1], this.playersHands[0]) ||
				existsDomino(this.dominoOnTable.get(0).getvalues()[0], this.playersHands[1]) ||
				existsDomino(this.dominoOnTable.get(this.dominoOnTable.size()-1).getvalues()[1], this.playersHands[1]))
				return false;
			else
				return true;
		}
		else {
			return false;
		}		
	}
	
	private  boolean existsDomino(int value, ArrayList<Domino> l) {
		for (Domino b:l) {			
			if ((b.getvalues()[0]==value) || (b.getvalues()[1]==value)) {
				return true;
			}				
		}
		return false;
	}
}