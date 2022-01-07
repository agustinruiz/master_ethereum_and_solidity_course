//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

contract AuctionCreator {
    Auction[] public auctions;

    function crateAuction() public {
        // We want that the owner of the new auction be the user who creates the auction not the address of the
        // AuctionCreator contract. For that we have to pass the eoa(External owned address) who called this function.
        Auction newAuction = new Auction(msg.sender);
        auctions.push(newAuction);
    }
}

contract Auction {
    address payable public owner;
    // IMPORTANTE: Las subastas requieren de un tiempo de inicio y fin. En solidity, el tiempo es tramposo ya que los timestamp de
    // los bloques son seteados por los mineros y pueden ser manipulados facilmente por ellos. Por ello no es seguro usar la variable
    // global llamada block.timestam. Una buena practica es calcular el tiempo basandose en el numero de bloque. Por ello declaro
    // dos variables globales que me ayudaran a calcular el tiempo de la subasta.
    uint256 public startBlock;
    uint256 public endBlock;

    // El producto a subastar seguramente tenga una descripcion (texto, imagenes, etc) que no conviene guardarlos en la blockcahin
    // ya que es muy caro. Por eso puede utilizar otra solucion desentralizada off-chain como por ejemplo IPFS (interplanetary file system)
    // Y lo que se guarda en la blockchain es un hash de lo guardado en IPFS.
    string public ipfsHash;

    // Tambien declaramos una variable de estado para ver en que estado esta la subasta:
    //
    enum State {
        Started,
        Running,
        Ended,
        Canceled
    }
    State public auctionState;

    // Variable de estado para guardar la maxima apuesta o el valor de venta
    uint256 public highestBindingBid;

    // Variable para almacenar el address del maximo ofertante
    address payable public highestBidder; // tiene que ser payable para que se puedan devolver los fondos si se cancela la subasta o hay una oferta mas alta

    // creo una variable mapping que almacene, para cada ofertante, el address y el valor ofertado
    mapping(address => uint256) public bids;

    // variable para guardar los incrementos de las ofertas
    uint256 bidIncrement;

    constructor(address eoa) {
        owner = payable(eoa); // hay que convertir el sender en payable ya que el owner tiene que recibir eth
        auctionState = State.Running;
        // Por lo mencionado anteriormente como IMPORTANTE. Una buena practica es calcular el tiempo basandose en el numero de bloque.
        // Sabemos que, en ethereum, el tiempo entre bloque y bloque son 50 segundos (se crea un bloque y se añade a la blockchain
        // apoximadamente cada 50 segundos).
        // Inicializo startBlock con el bloque actual ya que quiero iniciar la subasta ahora. Se puede iniciar en un futuro sabiendo que
        // cada bloque se crea cada 50 segundos.
        startBlock = block.number; // block.number es la variable global que devuelve el numero de bloque.
        // Supongamos que queremos que la subasta sea valida por una semana. cuanto deberia valer el endBlock? cuantos bloques de eth se
        // generan en una semana?
        // 60 segundos en 1 min * 60 minutos en una hora * 24 horas en 1 dia * 7 dias en una semana / 50 segundos por bloque = 40320.
        // se generan 40320 bloques en una semana.
        endBlock = startBlock + 40320; // Esto significa que la subasta estara funcionando por una semana.
        ipfsHash = "";
        bidIncrement = 100;
    }

    // not owner condition
    modifier notOwner() {
        require(msg.sender != owner);
        _;
    }

    // Only owner condition
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // after start condition
    modifier afterStart() {
        require(block.number >= startBlock);
        _;
    }

    // before end condition
    modifier beforeEnd() {
        require(block.number <= endBlock);
        _;
    }

    // In solidity there is no function that returns the minimum between two values. So we create it
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a <= b) {
            return a;
        } else {
            return b;
        }
    }

    // when somewone wants to place a bid
    // Modo de funcionamiento de la subasta:
    /* 
    El valor de venta va a estar dado por el segundo maximo apostador mas el bidIncrement. 
    Esto quiere decir que la persona que mas apuesta no necesariamente va a gastor todo el 
    capital ofertado sino que el incremento minimo + lo ofertado por el segundo maximo ofertador.
    Ej: 
    */
    function placeBid() public payable notOwner afterStart beforeEnd {
        // The auction must be in Running state
        require(auctionState == State.Running);
        // the bid must be grater than 100 weis
        require(msg.value >= 100);

        // Cero is the default value of any key in the mapping and also if the addres key does't exist
        uint256 currentBid = bids[msg.sender] + msg.value;

        // if the current bid is less than the highestBindingBid () the contract must stop because that is not allowed
        // you have to bid more than the actual price
        require(currentBid > highestBindingBid);

        // updating the bid of the sender
        bids[msg.sender] = currentBid;

        // if the current bid (previous bid + this bid) is less than the bid of the of the highest bidder:
        if (currentBid <= bids[highestBidder]) {
            // if the current bid (previous bid + this bid) is less than the bid of the of the highest bidder, I update
            // the highestBindingBid with the minimum between the current bid + the increment and the highest bid.
            highestBindingBid = min(
                currentBid + bidIncrement,
                bids[highestBidder]
            );
        } else {
            // if the current bid (previous bid + this bid) is more than the bid of the of the highest bidder, I update
            // the highestBindingBid with the minimum between the current bid and the highest bid + the increment.
            highestBindingBid = min(
                currentBid,
                bids[highestBidder] + bidIncrement
            );
            // In this case we also update the highest bidder
            highestBidder = payable(msg.sender);
        }
    }

    // Cancelling the auction
    // If a vulnerabilitty is found in the code, or anything bad happens the owner
    // has the posibility to cancel the auction so that all the bidders can request back their founds
    function cancelAuction() public onlyOwner {
        auctionState = State.Canceled;
    }

    // Finalizing the Auction
    function finalizeAuction() public {
        // we could finalize the auction if the auction is canceled or the time expired (Auction ended)
        require(auctionState == State.Canceled || block.number > endBlock);
        // the auction could be finalized by the owner or any bidder
        require(msg.sender == owner || bids[msg.sender] > 0); // "bids[msg.sender] > 0" mean only a bidder because just them could be in the bids mapping

        address payable recipient;
        uint256 value;

        // two possibilities: either the auction was canceled for the owner and every bidder could reclaim the money they sent
        // or the auction ended and the owner recieves the highest binding bid
        if (auctionState == State.Canceled) {
            // auction was cancelled
            recipient = payable(msg.sender);
            value = bids[msg.sender];
        } else {
            // Auction ended (not cancelled)
            if (msg.sender == owner) {
                // The owner comes to get his monney
                recipient = owner;
                value = highestBindingBid;
            } else {
                // The bidder want to claim his founds
                if (msg.sender == highestBidder) {
                    // the highest bidder is claming his founds
                    recipient = highestBidder;
                    value = bids[highestBidder] - highestBindingBid;
                } else {
                    // The rest of the bidders claiming
                    recipient = payable(msg.sender);
                    value = bids[msg.sender];
                }
            }
        }

        // So the recipient couldn't claim their founds more than once
        bids[recipient] = 0; // Now the recipient isn't consider a bidder

        // now we have to transfer the founds to the recipient
        recipient.transfer(value);
    }
}
