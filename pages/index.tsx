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

const landContractAddress = '0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9'
const juniorContractAddress = ''
const stakingContractAddress = '0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6'
const humanContractAddress = '0x5FbDB2315678afecb367f032d93F642f64180aa3'
const kaijuContractAddress = '0x851356ae760d987E095750cCeb3bC6014560891C'

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
  const [juniors, setJuniors] = useState([]);

  const getBalance = async() => {
    if(window.ethereum){
      const newAccounts = await window.ethereum.request({
        method: "eth_requestAccounts",
      });
      const provider = new ethers.providers.Web3Provider(window.ethereum)
      const signer = provider.getSigner()
      const landContract = new ethers.Contract(
        landContractAddress,
        landAbi.abi,
        signer
      )
      const response = await landContract.balanceOf(newAccounts[0])
      const number = await ethers.BigNumber.from( response ).toNumber()
      console.log(number)
    }
    
  }

  const mintKaiju = async() => {
    if(window.ethereum){
      const provider = new ethers.providers.Web3Provider(window.ethereum)
      const signer = provider.getSigner()
      const kaijuContract = new ethers.Contract(
        kaijuContractAddress,
        kaijuAbi.abi,
        signer
      )
      
      const price = await kaijuContract.pricePerToken()
      console.log(ethers.utils.formatEther( price ))
      var total = ethers.utils.formatEther( price )

      const options = {value: ethers.utils.parseEther("1.0")}
      const response = await kaijuContract.publicsale(ethers.utils.parseEther("1"), {
        gasLimit: 100000,
        nonce: undefined,
      })
      console.log(response)
    }
  }

  const mintLand = async() => {
    if(window.ethereum){
      const newAccounts = await window.ethereum.request({
        method: "eth_requestAccounts",
      })
      const provider = new ethers.providers.Web3Provider(window.ethereum)
      const signer = provider.getSigner()
      const landContract = new ethers.Contract(
        landContractAddress,
        landAbi.abi,
        signer
      )
      const humanContract = new ethers.Contract(
        humanContractAddress,
        humanAbi.abi,
        signer
      )
      // const approval = await humanContract.approve(landContractAddress, utils.parseEther('100'));
      // console.log('salat aprroval')
      const response = await landContract.mint(1)
      console.log('salat mint')
      console.log(response)
    }
  }

  const mintJunior = () => {

  }

  const stakeLand = async () => {
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const signer = provider.getSigner()
    const stakingContract = new ethers.Contract(
      stakingContractAddress,
      stakingAbi.abi,
      signer
    )
    const landContract = new ethers.Contract(
      landContractAddress,
      landAbi.abi,
      signer
    )
    const approval = await landContract.setApprovalForAll(stakingContractAddress, true);
    const response = await stakingContract.stake(1)
    console.log(response)
  }

  const getStaked = async () => {
    const newAccounts = await window.ethereum.request({
      method: "eth_requestAccounts",
    });
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const signer = provider.getSigner()
    const stakingContract = new ethers.Contract(
      stakingContractAddress,
      stakingAbi.abi,
      signer
    )
    const response = await stakingContract.getStakedTokens(newAccounts[0])
    console.log(response)
  }

  
  const stakeJunior = () => {

  }

  const raidLand = async () => {
    const newAccounts = await window.ethereum.request({
      method: "eth_requestAccounts",
    });
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const signer = provider.getSigner()
    const stakingContract = new ethers.Contract(
      stakingContractAddress,
      stakingAbi.abi,
      signer
    )
    const response = await stakingContract.raid(1, {
      gasLimit: 5000000,
    })
    console.log(response)
  }

  const test = async () => {
    const newAccounts = await window.ethereum.request({
      method: "eth_requestAccounts",
    });
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const signer = provider.getSigner()
    const stakingContract = new ethers.Contract(
      stakingContractAddress,
      stakingAbi.abi,
      signer
    )
    const response = await stakingContract.test(1)
    console.log(response)
  }

  const upgradeLand = async () => {
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const signer = provider.getSigner()
    const landContract = new ethers.Contract(
      landContractAddress,
      landAbi.abi,
      signer
    )
    const response = await landContract.getResistanceById(1)
    console.log(response)
  }
  return (
    <div>
      <button onClick={mintKaiju}>Mint Kaiju</button>
      <button onClick={mintLand}>Mint Land</button>
      <button onClick={mintJunior}>Mint Junior</button>
      <button onClick={stakeLand}>Stake Land</button>
      <button onClick={stakeJunior}>Stake Junior</button>
      <button onClick={getBalance}>balanceOf</button>
      <button onClick={getStaked}>getStaked</button>

      <button onClick={upgradeLand}>Upgrade</button> 
      <button onClick={raidLand}>Raid</button>
      <button onClick={test}>test</button>
    </div>
  )
}

export default Home