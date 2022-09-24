import type { NextPage } from 'next'
import Head from 'next/head'
import Image from 'next/image'
import { ethers, utils } from 'ethers'
import { useEffect, useState } from 'react'
import styles from '../styles/Home.module.css'
import humanAbi from '../artifacts/contracts/Human.sol/Human.json'
import juniorAbi from '../artifacts/contracts/JuniorKongzNFT.sol/JuniorKongzNFT.json'
import kaijuAbi from '../artifacts/contracts/KaijuKongz.sol/KaijuKongz.json'
import landAbi from '../artifacts/contracts/LandNFT.sol/LandNFT.json'
import stakingAbi from '../artifacts/contracts/StakingNFT.sol/StakingNFT.json'
import web3 from 'web3'
import Moralis from "moralis";
import { toast } from "react-toastify";

declare let window: any;

const landContractAddress = '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512'
const humanContractAddress = '0x5FbDB2315678afecb367f032d93F642f64180aa3'

const stakingContractAddress = '0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6'

const Home: NextPage = () => {
  const [lands, setLands] = useState([]);
  useEffect(() => {
    connectAccount()
  },[])
  const connectAccount = async () => {
    if (window.ethereum) {
      const newAccounts = await window.ethereum.request({
        method: "eth_requestAccounts",
      });
    } else {
      console.log('laaaaa')
      toast("You don't have metamask installed, please install metamaks to continue.",{ type: "error" } );
    }
  };

  const mintKaiju = async() => {
  }

  return (
    <div>
      <button onClick={mintKaiju}>Mint Kaiju</button>
    </div>
  )
}

export default Home