/**
 * AppComponent : Composant racine de l'application
 * Contient le formulaire de prise de commande
 */

import { Component } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { OrderService } from './order.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  orderForm: FormGroup;
  submitted = false;
  successMessage: string | null = null;
  errorMessage: string | null = null;
  isLoading = false;

  constructor(
    private fb: FormBuilder,
    private orderService: OrderService
  ) {
    this.orderForm = this.createForm();
  }

  createForm(): FormGroup {
    return this.fb.group({
      customerName: ['', [Validators.required, Validators.minLength(2)]],
      email: ['', [Validators.required, Validators.email]],
      itemDescription: ['', [Validators.required, Validators.minLength(5)]],
      quantity: ['', [Validators.required, Validators.min(1)]],
      price: ['', [Validators.required, Validators.min(0)]]
    });
  }

  /**
   * Soumet le formulaire
   * Envoie les données au backend via OrderService
   */
  onSubmit(): void {
    this.submitted = true;
    this.successMessage = null;
    this.errorMessage = null;

    if (this.orderForm.valid) {
      this.isLoading = true;

      // Affichage dans la console du frontend
      console.log('📝 Formulaire soumis avec les données:');
      console.log(this.orderForm.value);

      this.orderService.createOrder(this.orderForm.value).subscribe({
        next: (response) => {
          this.isLoading = false;
          console.log('✅ Commande créée avec succès:', response);
          this.successMessage = `Commande de ${response.customerName} créée avec succès!`;
          this.orderForm.reset();
          this.submitted = false;
        },
        error: (error) => {
          this.isLoading = false;
          console.error('❌ Erreur lors de la création de la commande:', error);
          this.errorMessage = 'Erreur lors de la création de la commande. Vérifiez la console du navigateur.';
        }
      });
    }
  }

  get f() {
    return this.orderForm.controls;
  }

}
