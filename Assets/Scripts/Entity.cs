using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

[RequireComponent(typeof(Animator))]
public class Entity : MonoBehaviour
{
    [SerializeField] private ParticleSystem _fx = null;

    private float _energy = 0f;
    private Animator _animator = null;

    private void Awake()
    {
        _animator = GetComponent<Animator>();
        if (_animator == null)
        {
            Debug.LogError("No Component Animator found.");
            return;
        }
    }
    void Start()
    {

    }
    void Update()
    {

    }

    public void PlayFX()
    {
        _fx.Play();
    }
    public void DoSmallJump()
    {
        _animator.SetTrigger("SmallJump");
    }
    public void DoBigJump()
    {
        _animator.SetTrigger("BigJump");
    }
}
