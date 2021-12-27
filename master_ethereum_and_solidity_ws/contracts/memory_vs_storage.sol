//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;

contract MmemoryVsStorage{
    string[] public cities = ["Cordoba", "Salta"]; // Esta variable esta alocada en el storage del contrato

    function f_memory() public view{
        string[] memory s1 = cities; // Esta variable esta alocada en memoria por lo que se copia el contenido de cities
        //string[] s1; -> Da error ya que para los arrays se debe especificar si estan en storage o en memoria
        s1[0] = "Neuquen"; // no modifica la variable de storage
    }

    function f_storage() public{
        string[] storage s1 = cities; // Esta variable esta pasa a hacer referencia a cities en el storage
        //string[] s1; -> Da error ya que para los arrays se debe especificar si estan en storage o en memoria
        s1[0] = "Neuquen"; // Si modifica la variable de storage
    }
}