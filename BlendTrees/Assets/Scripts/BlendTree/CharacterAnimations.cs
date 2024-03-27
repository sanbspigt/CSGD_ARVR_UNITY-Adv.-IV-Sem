using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterAnimations : MonoBehaviour
{
    private Animator charAnim;

    bool isWalking;
    int walkingHash;
    int velHash;

    float currVelocity = 0.0f;
    [SerializeField] float velMultiplier;

    bool isRunning;
    int runningHash;

    bool walkInput, runInput;

    private void Awake()
    {
        charAnim = GetComponent<Animator>();
        walkingHash = Animator.StringToHash("isWalking");
        runningHash = Animator.StringToHash("isRunning");
        velHash = Animator.StringToHash("velocity");

        currVelocity = 0.1f;
    }

    private void Update()
    {

        /*isWalking = charAnim.GetBool(walkingHash);
        isRunning = charAnim.GetBool(runningHash);*/

        walkInput = Input.GetKey(KeyCode.W);
        runInput = Input.GetKey(KeyCode.LeftShift);

        if (walkInput )
        {
            currVelocity += Time.deltaTime * velMultiplier;
            charAnim.SetFloat(velHash,currVelocity);
        }
        else if (!walkInput)
        {
            currVelocity -= Time.deltaTime * velMultiplier;
            charAnim.SetFloat(velHash, currVelocity);
        }

        if (currVelocity <= 0.1f)
        {
            currVelocity = 0.1f;
        }


        if (!isWalking && walkInput)
        {
            charAnim.SetBool(walkingHash, true);
        }
        else if(!walkInput)
        {
            charAnim.SetBool(walkingHash, false);
        }

        if (isWalking && runInput)
        {
            charAnim.SetBool(runningHash, true);
        }
        else if(!runInput)
        {
            charAnim.SetBool(runningHash, false);
        }
        
    }
}
