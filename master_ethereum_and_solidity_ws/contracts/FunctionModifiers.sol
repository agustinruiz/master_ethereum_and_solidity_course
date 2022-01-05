//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Property {
    uint256 public price;
    address public owner;

    // Una funcion modifier debe terminar con la sentencia _;
    // la sentencia _; lo que indica es donde se insertara el cuerpo de la funcion a la que se aplica. Por lo que si
    // agrego una sentencia despues de _; se ejecutara despues de la funcion.
    modifier onlyOwner() {
        require(owner == msg.sender);
        _; // lo que hace esta sentencia es insertar el cuerpo de la funcion a la que se aplica el modifier. en este caso primero ejecuta el require y luego la funcion
    }

    // declaring the constructor
    constructor() {
        price = 0;
        owner = msg.sender;
    }

    function changeOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }
}
