using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotator : MonoBehaviour
{

    [Range(1.0f, 20.0f)]
    public float speed = 5.0f;
    private float r;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        r += +Time.deltaTime * speed;
        var e = new Vector3(0.0f, r, 0.0f);
        gameObject.transform.rotation = Quaternion.Euler(e.x, e.y, e.z);
    }
}
