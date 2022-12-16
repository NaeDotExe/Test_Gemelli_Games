using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

[RequireComponent(typeof(Animator), typeof(Rigidbody))]
public class Entity : MonoBehaviour
{
    #region Attributes
    [SerializeField] private ParticleSystem _fx = null;

    private float _energy = 0f;
    private Animator _animator = null;
    private Rigidbody _rigidBody = null;
    #endregion

    #region Methods
    private void Awake()
    {
        _animator = GetComponent<Animator>();
        if (_animator == null)
        {
            Debug.LogError("No Component Animator found.");
            return;
        }

        _rigidBody = GetComponent<Rigidbody>();
        if (_rigidBody == null)
        {
            Debug.LogError("No Component Rigidbody found.");
            return;
        }
    }

    public void PlayFX()
    {
        _fx.Play();
    }
    public void DoSmallJump()
    {
        //_rigidBody.AddForce();
        _animator.SetTrigger("SmallJump");
    }
    public void DoBigJump()
    {
        //_rigidBody.AddForce();
        _animator.SetTrigger("BigJump");
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.tag != "Floor")
        {
            return;
        }

        _fx.Play();
    }
    #endregion
}
