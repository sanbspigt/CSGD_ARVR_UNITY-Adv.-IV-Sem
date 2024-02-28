using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(CharacterController))]
// This class controls the player character's movement and rotation in the game world.
public class RailPlayerController : MonoBehaviour
{
    // Movement speed of the player.
    [SerializeField] float moveSpeed = 5f;
    // Rotation speed of the player.
    [SerializeField] float rotationSpeed = 500f;

    [Header("Ground Check Settings")]
    // Radius of the sphere used to check if the player is on the ground.
    [SerializeField] float groundCheckRadius = 0.2f;
    // Offset from the player's position to perform the ground check.
    [SerializeField] Vector3 groundCheckOffset;
    // LayerMask defining what layers constitute the ground.
    [SerializeField] LayerMask groundLayer;

    // Boolean indicating if the player is currently grounded.
    bool isGrounded;

    // Vertical speed of the player, used for applying gravity.
    float ySpeed;
    // Target rotation of the player based on movement input.
    Quaternion targetRotation;

   
    // CharacterController component for movement and collision detection.
    CharacterController characterController;

    private void Awake()
    {
       
        // Get the CharacterController component attached to this gameObject.
        characterController = GetComponent<CharacterController>();
    }

    private void Update()
    {
        // Get horizontal and vertical input from the player.
        float h = Input.GetAxis("Horizontal");
        float v = Input.GetAxis("Vertical");

        // Calculate the overall movement amount to determine if the player is moving.
        float moveAmount = Mathf.Clamp01(Mathf.Abs(h) + Mathf.Abs(v));

        // Normalize the input vectors to get a direction of movement.
        var moveInput = (new Vector3(h, 0, v)).normalized;

        // Convert the input direction into world space based on the camera's rotation.
        var moveDir = moveInput;

        // Check if the player is on the ground.
        GroundCheck();
        if (isGrounded)
        {
            // Apply a small downward force to keep the player grounded.
            ySpeed = -0.5f;
        }
        else
        {
            // Apply gravity to the player when not grounded.
            ySpeed += Physics.gravity.y * Time.deltaTime;
        }

        // Calculate the final velocity vector including movement and gravity.
        var velocity = moveDir * moveSpeed;
        velocity.y = ySpeed;

        // Move the player using the CharacterController.
        characterController.Move(velocity * Time.deltaTime);

        // Rotate the player to face the direction of movement.
        if (moveAmount > 0)
        {
            targetRotation = Quaternion.LookRotation(moveDir);
        }
        transform.rotation = Quaternion.RotateTowards(transform.rotation, targetRotation,
            rotationSpeed * Time.deltaTime);
    }

    // Performs a sphere check to determine if the player is grounded.
    void GroundCheck()
    {
        isGrounded = Physics.CheckSphere(transform.TransformPoint(groundCheckOffset), groundCheckRadius, groundLayer);
    }

    // Visualize the ground check sphere in the editor.
    private void OnDrawGizmosSelected()
    {
        Gizmos.color = new Color(0, 1, 0, 0.5f);
        Gizmos.DrawSphere(transform.TransformPoint(groundCheckOffset), groundCheckRadius);
    }
}