# sui-unity_sdk

## How to integrate Sui Unity SDK into Unity?


To integrate the Sui Unity SDK into your Unity project, you will need to take the following steps:

1. First, make sure that you have downloaded the latest version of the Sui Unity SDK from the official Sui website.

2. Once you have downloaded the SDK, you will need to import it into your Unity project. To do this, go to Assets -> Import Package -> Custom Package and select the package that you downloaded.

3. After importing the package, you will need to set up the Unity scene to work with the Sui SDK. You can do this by adding the "SuiCanvas" prefab to your scene. This prefab contains a canvas and a script that initializes the Sui SDK.

4. Finally, you will need to initialize the Sui SDK and set up any necessary configurations in your script. This can be done using the "SuiManager" class provided in the SDK.

For a more detailed explanation, including sample code, please refer to the documentation provided by Sui in the SDK package or on their website.


## What are the features provided in the SDK?

  To use the Sui Unity SDK, you need to be familiar with the various features provided in the SDK. Some features include:

1. Backend and frontend separation functionality

2. Data upload functionality

3. Data retrieval functionality

4. Event reporting

5. Custom UI component library

- What should be noted?

## When using the Sui Unity SDK, please note the following:

1. Make sure you have imported the SDK correctly and follow the usage instructions provided in the Sui documentation.

2. Before using the SDK, please read the documentation to ensure that you are familiar with all the features and requirements of using the SDK.

3. Be careful not to leak sensitive data and consider checking and deleting all code or information that may contain sensitive data before publishing.


## Some examples

The code examples for using RPCs in Unity depend on which RPC library you choose to use. Here are two examples that may be helpful:

1. Photon Unity Networking（PUN）

```c#
using Photon.Pun;
using UnityEngine;

public class SomeScript : MonoBehaviourPun
{
[PunRPC]
void SomeRPCFunction(string someParameter)
{
Debug.Log("Received RPC with parameter: " + someParameter);
}

    void CallRPC()
    {
        photonView.RPC("SomeRPCFunction", RpcTarget.All, "someParameter");
    }
}
```

In this example, we define an RPC function called "SomeRPCFunction" and call it in the "CallRPC" function. The function has a string parameter that will be passed to other clients when the function is called. When calling the RPC, we use the "photonView.RPC" function and set the target to "RpcTarget.All" (send the RPC to all clients).


```c#
using Mirror;
using UnityEngine;

public class SomeScript : NetworkBehaviour
{
[TargetRpc]
void RpcSomeFunction(NetworkConnection target, string someParameter)
{
Debug.Log("Received RPC with parameter: " + someParameter);
}

    void CallRPC()
    {
        RpcSomeFunction(connectionToServer, "someParameter");
    }
}
```

In this example, we define an RPC function called "RpcSomeFunction" and call it in the "CallRPC" function. The function has a string parameter that will be passed to the server when the function is called, and will be sent to the target client via the "target" parameter. When calling the RPC, we use the "RpcSomeFunction" function and set the target to the connection of the client we want to send the RPC to.

Please note that these examples are conceptual proof-of-concepts and should not be copy-pasted directly into your code. You should modify these examples to suit your specific needs in order to use RPCs correctly in your project.

