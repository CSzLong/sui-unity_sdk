using UnityEngine;  
using UnityEngine.Networking;  
using UnityEngine.Networking.RPC;  
using UnityEngine.UI;  
using UnityEngine.EventSystems;  
using System.Collections;  
using System.Collections.Generic;  
using System.Runtime.InteropServices;  
using System.Threading.Tasks;  
using System;  
using UnityEngine.UI;  
using UnityEngine.EventSystems;  
using System.Collections;  
using System.Collections.Generic;  
using System.Runtime.InteropServices;  
using System.Threading.Tasks;  
using System;  
using UnityEngine.UI;  
using UnityEngine.EventSystems;  
using System.Collections;  
using System.Collections.Generic;  
using System.Runtime.InteropServices;  
using System.Threading.Tasks;  

public class RPCCallbackHandler : MonoBehaviour, RPCHandler {  
    public void OnRpcCompleted(RPCCallback<T> result) {  
        if (result.success) {  
            text.text = result.result.ToString();  
        } else {  
            text.text = result.errorMessage;  
        }  
    }  
}

public class MyClass : MonoBehaviour, IPointerClickHandler {  
    public Text text;  
    void Start() {  
        RPCCallbackHandler callbackHandler = new RPCCallbackHandler();  
        MyClassInstance.rpcManager.Register(callbackHandler); // 将RPCCallbackHandler注册到RPC管理器中  
        text.text = "Click me!";  
    }  
    public void OnPointerClick(PointerEventData eventData) {  
        MyRpcMethod(123, 456); // 调用RPC方法并传递参数  
    }  
}