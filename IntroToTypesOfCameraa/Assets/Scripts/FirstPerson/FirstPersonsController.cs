using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(CharacterController))]
public class FirstPersonsController : MonoBehaviour
{
    // Define yaw (rotation around the y-axis) limits for camera rotation.
    public float MinYaw = -360;
    public float MaxYaw = 360;
    // Define pitch (rotation around the x-axis) limits for camera look up/down.
    public float MinPitch = -60;
    public float MaxPitch = 60;
    // Sensitivity of look movement.
    public float LookSensitivity = 1;

    // Movement speed variables.
    public float MoveSpeed = 10;
    public float SprintSpeed = 30;
    private float currMoveSpeed = 0; // Current movement speed.

    // References to the character controller and camera components.
    protected CharacterController movementController;
    protected Camera playerCamera;

    // Control state variable.
    protected bool isControlling;

    // Current rotation values.
    protected float yaw;
    protected float pitch;

    // Current movement velocity.
    protected Vector3 velocity;


    protected virtual void Start()
    {
        // Initialize character controller and camera components.
        movementController = GetComponent<CharacterController>();
        playerCamera = GetComponentInChildren<Camera>();

        // Enable player control by default.
        isControlling = true;
        ToggleControl(); // Apply control settings.
    }

    protected virtual void Update()
    {

        #region Movement Logic
        // Calculate movement direction.
        Vector3 direction = Vector3.zero;
        direction += transform.forward * Input.GetAxisRaw("Vertical");
        direction += transform.right * Input.GetAxisRaw("Horizontal");

        // Normalize to prevent faster diagonal movement.
        direction.Normalize();

        // Reset vertical velocity when grounded.
        if (movementController.isGrounded)
        {
            velocity = Vector3.zero;
        }
        else
        {
            // Apply gravity if not grounded.
            velocity += -transform.up * (9.81f * 10) * Time.deltaTime;
        }

        // Adjust speed based on sprint key (Left Shift).
        if (Input.GetKey(KeyCode.LeftShift))
        {
            currMoveSpeed = SprintSpeed;
        }
        else
        {
            currMoveSpeed = MoveSpeed;
        }

        // Apply movement and gravity.
        direction += velocity * Time.deltaTime;
        movementController.Move(direction * Time.deltaTime * currMoveSpeed);
        #endregion

        #region Camera Calculations
        // Adjust camera look direction based on mouse movement.
        yaw += Input.GetAxisRaw("Mouse X") * LookSensitivity;
        pitch -= Input.GetAxisRaw("Mouse Y") * LookSensitivity;

        // Clamp camera rotation to prevent excessive rotation.
        yaw = ClampAngle(yaw, MinYaw, MaxYaw);
        pitch = ClampAngle(pitch, MinPitch, MaxPitch);

        // Apply rotation to the player object.
        transform.eulerAngles = new Vector3(0.0f, yaw, 0.0f);
        // Apply pitch rotation to just the camera, for looking up and down.
        playerCamera.transform.localEulerAngles = new Vector3(pitch, 0.0f, 0.0f);
        #endregion
    }

    // A helper method to clamp angles within a given range.
    protected float ClampAngle(float angle, float min, float max)
    {
        if (angle < -360F)
            angle += 360F;
        if (angle > 360F)
            angle -= 360F;
        return Mathf.Clamp(angle, min, max);
    }

    // Toggle player control and cursor state.
    protected void ToggleControl()
    {
        // Activate or deactivate the camera based on control state.
        playerCamera.gameObject.SetActive(isControlling);
        // Lock or unlock the cursor based on control state.
        Cursor.lockState = isControlling ? CursorLockMode.Locked : CursorLockMode.None;
        Cursor.visible = !isControlling;
    }

}
